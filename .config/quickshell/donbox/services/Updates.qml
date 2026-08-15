pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property int millisecondsPerHour: 3600000
    readonly property int checkIntervalHours: 3
    readonly property int settleDelayMs: 120000
    readonly property int saveDelayMs: 1000

    readonly property int checkIntervalMs:
        root.checkIntervalHours * root.millisecondsPerHour

    // dnf lists one package per line as name.arch, version and
    // repository; headings and the indented obsoletion notes it
    // adds underneath do not match that shape.
    readonly property var packageLine: /^\S+\.\S+\s+\S+\s+\S+$/

    // dnf answers 100 when it found something and 0 when it did
    // not; anything else means it never got to look.
    readonly property var answeredCodes: [0, 100]

    readonly property string glyph: "󰚰"

    readonly property string stateHome:
        Quickshell.env("XDG_STATE_HOME")
        ?? `${Quickshell.env("HOME")}/.local/state`

    readonly property string directory: `${root.stateHome}/donbox`
    readonly property string path: `${root.directory}/updates.json`

    property int pending: 0
    property string harvest: ""
    property real checkedAtMs: 0
    property bool checking: false

    readonly property bool offered: root.pending > 0

    readonly property real dueInMs: Math.max(0,
        root.checkedAtMs + root.checkIntervalMs - Date.now())

    readonly property string countText: `${root.pending}`

    readonly property string summary: root.pending === 1
        ? "1 update available"
        : `${root.pending} updates available`

    function countIn(payload: string): int {
        return payload.split("\n")
            .filter(line => root.packageLine.test(line))
            .length;
    }

    // A failed check keeps the last count rather than claiming
    // there is nothing to install, and waits out the usual
    // interval instead of retrying in a tight loop.
    function settle(code: int): void {
        root.checking = false;
        root.checkedAtMs = Date.now();
        if (root.answeredCodes.includes(code)) {
            root.pending = root.countIn(root.harvest);
        } else {
            console.error("donbox: dnf could not check for updates");
        }
        writeBack.restart();
    }

    function check(): void {
        if (root.checking) return;
        root.checking = true;
        reader.running = true;
    }

    function save(): void {
        file.setText(JSON.stringify({
            pending: root.pending,
            checkedAtMs: root.checkedAtMs
        }));
    }

    function reparse(): void {
        try {
            const saved = JSON.parse(file.text());
            root.pending = saved.pending ?? 0;
            root.checkedAtMs = saved.checkedAtMs ?? 0;
        } catch (error) {
            root.checkedAtMs = 0;
        }
    }

    Component.onCompleted: {
        Quickshell.execDetached(["mkdir", "-p", root.directory]);
        root.reparse();
    }

    // Asking dnf costs a network round trip, so a session that
    // restarts inside the interval keeps the cached answer and
    // only waits out whatever is left of it.
    Timer {
        running: true
        repeat: true
        interval: Math.max(root.settleDelayMs, root.dueInMs)

        onTriggered: root.check()
    }

    Timer {
        id: writeBack

        interval: root.saveDelayMs

        onTriggered: root.save()
    }

    Process {
        id: reader

        command: ["dnf", "--quiet", "check-update"]

        onExited: code => root.settle(code)

        stdout: StdioCollector {
            onStreamFinished: root.harvest = this.text
        }
    }

    FileView {
        id: file

        path: root.path
        blockLoading: true
        atomicWrites: true
        printErrors: false
    }
}
