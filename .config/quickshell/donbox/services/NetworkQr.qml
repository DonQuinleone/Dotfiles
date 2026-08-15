pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property int moduleSizePixels: 6
    readonly property int quietZoneModules: 4
    readonly property int rgbDigits: 6
    readonly property string errorCorrection: "M"
    readonly property string secretKey: "802-11-wireless-security.psk"

    readonly property var reservedMarks: ["\\", ";", ",", ":", "\""]

    readonly property string missingToolTrouble:
        "Install qrencode to share this network as a code."
    readonly property string lockedSecretTrouble:
        "The saved password cannot be read without authenticating."
    readonly property string openNetworkTrouble:
        "This network has no password to share."
    readonly property string drawTrouble:
        "qrencode could not draw the code."

    readonly property string runtimeDir:
        Quickshell.env("XDG_RUNTIME_DIR") ?? "/tmp"

    readonly property string imagePath:
        `${root.runtimeDir}/donbox-wifi-qr.png`

    readonly property url imageSource: `file://${root.imagePath}`

    readonly property bool lightForeground:
        Theme.luminance(Theme.palette.fg ?? "white")
        >= Theme.luminance(Theme.palette.bg ?? "black")

    readonly property color plate: root.lightForeground
        ? (Theme.palette.fg ?? "white")
        : (Theme.palette.bg ?? "black")

    readonly property color ink: root.lightForeground
        ? (Theme.palette.bg ?? "black")
        : (Theme.palette.fg ?? "white")

    property bool available: false
    property bool shown: false
    property bool drawing: false
    property bool drawn: false
    property string secret: ""
    property string trouble: ""

    readonly property string subject: Connectivity.ssid

    readonly property bool offered:
        Connectivity.wifiConnected && NetworkLink.wireless

    readonly property bool ready: root.shown && root.offered

    readonly property string payload:
        `WIFI:T:WPA;S:${root.escaped(root.subject)};`
        + `P:${root.escaped(root.secret)};;`

    function escaped(value: string): string {
        let result = "";
        for (const letter of value) {
            if (root.reservedMarks.includes(letter)) result += "\\";
            result += letter;
        }
        return result;
    }

    function hexOf(shade: color): string {
        const digits = shade.toString().replace("#", "");
        if (digits.length <= root.rgbDigits) return digits;
        return digits.slice(digits.length - root.rgbDigits);
    }

    function forget(): void {
        root.drawn = false;
        root.secret = "";
        root.trouble = "";
    }

    function unlock(): void {
        if (!root.available) {
            root.trouble = root.missingToolTrouble;
            return;
        }
        if (!Connectivity.secured(Connectivity.network)) {
            root.trouble = root.openNetworkTrouble;
            return;
        }
        if (reader.running) return;
        reader.running = true;
    }

    function judge(code: int): void {
        if (code === 0 && root.secret !== "") {
            root.draw();
            return;
        }
        root.secret = "";
        root.trouble = root.lockedSecretTrouble;
    }

    function draw(): void {
        if (drawer.running) return;
        root.drawing = true;
        drawer.stdinEnabled = true;
        drawer.running = true;
    }

    function finish(code: int): void {
        root.drawing = false;
        root.drawn = code === 0;
        root.trouble = root.drawn ? "" : root.drawTrouble;
    }

    onSubjectChanged: root.forget()

    onReadyChanged: {
        root.forget();
        if (root.ready) root.unlock();
    }

    Process {
        running: true
        command: ["sh", "-c", "command -v qrencode"]

        onExited: code => root.available = code === 0
    }

    Process {
        id: reader

        command: ["nmcli", "-s", "-g", root.secretKey,
            "connection", "show", NetworkLink.connectionUuid]

        stdout: StdioCollector {
            onStreamFinished: root.secret = this.text.trim()
        }

        onExited: code => root.judge(code)
    }

    Process {
        id: drawer

        command: ["qrencode", "-8",
            "-t", "PNG",
            "-o", root.imagePath,
            "-s", `${root.moduleSizePixels}`,
            "-m", `${root.quietZoneModules}`,
            "-l", root.errorCorrection,
            `--foreground=${root.hexOf(root.ink)}`,
            `--background=${root.hexOf(root.plate)}`]

        onStarted: {
            drawer.write(root.payload);
            drawer.stdinEnabled = false;
        }

        onExited: code => root.finish(code)
    }
}
