pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pam

Singleton {
    id: root

    readonly property string pamConfig: "login"
    readonly property string defaultInstruction: "Password"
    readonly property int retryDelayMs: 400
    readonly property int stallRetryMs: 2000

    readonly property string runtimeDir:
        Quickshell.env("XDG_RUNTIME_DIR") ?? "/tmp"
    readonly property string markerPath:
        `${root.runtimeDir}/donbox-session-locked`

    readonly property var refusals: ({
        [PamResult.Failed]: "Not recognised. Try again.",
        [PamResult.MaxTries]: "Too many attempts. Try again.",
        [PamResult.Error]: "Authentication error. Try again."
    })

    property bool locked: false
    property string entry: ""
    property string pending: ""
    property string instruction: root.defaultInstruction
    property string notice: ""

    // The fingerprint prompt asks for no response yet still
    // announces echo, so only an explicit request unmasks.
    readonly property bool masked:
        !(pam.responseRequired && pam.responseVisible)
    readonly property bool working: pam.active && !pam.responseRequired

    signal rejected

    function lock(): void {
        if (root.locked) return;
        root.locked = true;
        root.begin();
    }

    function unlock(): void {
        if (!root.locked) return;
        pam.active = false;
        root.forget();
        root.locked = false;
    }

    function begin(): void {
        root.forget();
        pam.active = false;
        if (pam.start()) return;
        root.notice = "Authentication is unavailable.";
        stall.restart();
    }

    function forget(): void {
        root.entry = "";
        root.pending = "";
        root.notice = "";
        root.instruction = root.defaultInstruction;
    }

    function submit(): void {
        if (root.entry === "") return;
        root.pending = root.entry;
        root.entry = "";
        root.flush();
    }

    function flush(): void {
        if (!pam.responseRequired || root.pending === "") return;
        const response = root.pending;
        root.pending = "";
        pam.respond(response);
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

    function refuse(reason: string): void {
        root.entry = "";
        root.pending = "";
        root.notice = reason;
        root.rejected();
        retry.restart();
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
        id: pam

        config: root.pamConfig

        onPamMessage: {
            const text = root.tidy(this.message);
            if (this.messageIsError) root.notice = text;
            else root.instruction = text;
            root.flush();
        }

        onCompleted: result => {
            if (result === PamResult.Success) {
                root.unlock();
                return;
            }
            root.refuse(root.refusals[result]
                ?? "Authentication failed. Try again.");
        }

        onError: error => root.refuse(
            `Authentication error (${PamError.toString(error)}).`)
    }

    Timer {
        id: retry

        interval: root.retryDelayMs

        onTriggered: {
            if (!root.locked) return;
            pam.active = false;
            pam.start();
        }
    }

    Timer {
        id: stall

        interval: root.stallRetryMs

        onTriggered: if (root.locked) root.begin()
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
