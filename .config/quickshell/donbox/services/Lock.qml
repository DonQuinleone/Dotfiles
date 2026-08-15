pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pam

Singleton {
    id: root

    // pam_fprintd holds a conversation for as long as it waits
    // for a finger, so a stack carrying both it and pam_unix can
    // never take a typed password meanwhile. Each factor gets its
    // own stack and its own conversation instead, which is what
    // authselect ships password-auth and fingerprint-auth for.
    readonly property var passwordConfigs: ["password-auth", "login"]
    readonly property var fingerprintConfigs: ["fingerprint-auth"]

    readonly property string defaultInstruction: "Password"
    readonly property int retryDelayMs: 400
    readonly property int stallRetryMs: 2000
    readonly property int fingerprintRetryMs: 1200
    readonly property int traceLimit: 6

    readonly property string runtimeDir:
        Quickshell.env("XDG_RUNTIME_DIR") ?? "/tmp"
    readonly property string markerPath:
        `${root.runtimeDir}/donbox-session-locked`
    readonly property var refusals: ({
        [PamResult.Failed]: "wrong password",
        [PamResult.MaxTries]: "too many attempts",
        [PamResult.Error]: "authentication error"
    })

    property bool locked: false
    property string entry: ""
    property string pending: ""
    property string instruction: root.defaultInstruction
    property string notice: ""
    property string fingerprintNote: ""
    property bool fingerprintReady: false
    property bool fingerprintPrompted: false
    property bool verifying: false
    property var trace: []

    // The fingerprint prompt asks for no response yet still
    // announces echo, so only an explicit request unmasks.
    readonly property bool masked:
        !(password.responseRequired && password.responseVisible)
    readonly property bool denied: root.notice !== ""

    signal rejected

    function lock(): void {
        if (root.locked) return;
        root.locked = true;
        root.trace = [];
        root.note("ok", "session locked");
        root.begin();
    }

    function unlock(): void {
        if (!root.locked) return;
        root.note("ok", "access granted");
        root.halt(password);
        root.halt(fingerprint);
        root.forget();
        root.locked = false;
    }

    function begin(): void {
        root.forget();
        if (root.restartPassword()) {
            root.note("ok", `pam ${password.config} open`);
        }
        root.restartFingerprint();
    }

    function halt(context): void {
        if (!context.active) return;
        context.abort();
        context.active = false;
    }

    function open(context, names): bool {
        root.halt(context);
        for (const name of names) {
            context.config = name;
            if (context.start()) return true;
        }
        return false;
    }

    function restartPassword(): bool {
        if (root.open(password, root.passwordConfigs)) return true;
        root.fault("authentication is unavailable");
        return false;
    }

    // The reader lapses on its own timeout every half minute, so
    // only a change of footing is worth a line in the trace.
    function restartFingerprint(): void {
        root.fingerprintPrompted = false;
        const armed =
            root.open(fingerprint, root.fingerprintConfigs);
        if (armed !== root.fingerprintReady) {
            root.note(armed ? "ok" : "warn",
                armed ? "fingerprint armed" : "fingerprint offline");
        }
        if (!armed) root.fingerprintNote = "";
        root.fingerprintReady = armed;
    }

    // A round that never asked for a finger has no reader behind
    // it, and rearming would spin the sensor for nothing.
    function retryFingerprint(): void {
        if (!root.locked) return;
        if (root.fingerprintPrompted) {
            fingerprintRetry.restart();
            return;
        }
        if (!root.fingerprintReady) return;
        root.fingerprintReady = false;
        root.fingerprintNote = "";
        root.note("warn", "fingerprint offline");
    }

    function forget(): void {
        root.entry = "";
        root.pending = "";
        root.notice = "";
        root.instruction = root.defaultInstruction;
        root.fingerprintReady = false;
        root.fingerprintNote = "";
        root.verifying = false;
    }

    function submit(): void {
        if (root.entry === "") return;
        root.pending = root.entry;
        root.entry = "";
        root.verifying = true;
        root.note("info", "verifying password");
        root.flush();
    }

    // A password typed before pam has asked for one waits here
    // rather than being dropped, so the field is live from the
    // moment the surface appears.
    function flush(): void {
        if (!password.responseRequired) return;
        if (root.pending === "") return;
        const response = root.pending;
        root.pending = "";
        password.respond(response);
    }

    function append(text: string): void {
        root.notice = "";
        root.entry += text;
    }

    function erase(): void {
        root.entry = root.entry.slice(0, -1);
    }

    function clear(): void {
        root.entry = "";
    }

    function deny(reason: string): void {
        root.reject(reason);
        root.rearm(root.retryDelayMs);
    }

    function fault(reason: string): void {
        root.reject(reason);
        root.rearm(root.stallRetryMs);
    }

    function rearm(delayMs: int): void {
        retry.interval = delayMs;
        retry.restart();
    }

    function reject(reason: string): void {
        root.entry = "";
        root.pending = "";
        root.verifying = false;
        root.notice = reason;
        root.note("deny", `access denied: ${reason}`);
        root.rejected();
    }

    function note(tag: string, text: string): void {
        const last = root.trace[root.trace.length - 1];
        if (last?.tag === tag && last?.text === text) return;
        root.trace = root.trace
            .concat([{ tag: tag, text: text }])
            .slice(-root.traceLimit);
    }

    // PAM prompts arrive punctuated for a terminal, which reads
    // badly at the size this screen renders them.
    function tidy(message: string): string {
        return message.replace(/[:\s]+$/, "");
    }

    onLockedChanged: Quickshell.execDetached(root.locked
        ? ["touch", root.markerPath]
        : ["rm", "--force", root.markerPath])

    PamContext {
        id: password

        onPamMessage: {
            const text = root.tidy(this.message);
            if (this.messageIsError) root.note("warn", text);
            else root.instruction = text;
            root.flush();
        }

        onResponseRequiredChanged: root.flush()

        onCompleted: result => {
            if (result === PamResult.Success) {
                root.unlock();
                return;
            }
            root.deny(root.refusals[result]
                ?? "authentication failed");
        }

        onError: error => root.fault(
            `pam error: ${PamError.toString(error)}`)
    }

    PamContext {
        id: fingerprint

        onPamMessage: {
            root.fingerprintPrompted = true;
            root.fingerprintNote = root.tidy(this.message);
            if (!this.messageIsError) return;
            root.note("warn", root.fingerprintNote);
        }

        onCompleted: result => {
            if (result !== PamResult.Success) {
                root.retryFingerprint();
                return;
            }
            root.note("ok", "fingerprint matched");
            root.unlock();
        }

        onError: root.retryFingerprint()
    }

    Timer {
        id: retry

        onTriggered: if (root.locked) root.restartPassword()
    }

    Timer {
        id: fingerprintRetry

        interval: root.fingerprintRetryMs

        onTriggered: if (root.locked) root.restartFingerprint()
    }

    // A locker that died with the session still locked leaves
    // the compositor showing nothing until one attaches again.
    Process {
        running: true
        command: ["test", "-e", root.markerPath]

        onExited: code => {
            if (code === 0) root.lock();
        }
    }
}
