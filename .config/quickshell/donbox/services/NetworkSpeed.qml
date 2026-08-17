pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property var script: [Preferences.donbox, "network", "speed"]

    readonly property string idleWords: "Not measured yet"
    readonly property string busyWords: "Measuring, about a quarter"
        + " of a minute"
    readonly property string unit: "Mb/s"
    readonly property string missingText: "—"

    property string down: ""
    property string up: ""
    property date takenAt: new Date(0)

    readonly property bool running: probe.running
    readonly property bool measured: root.down !== ""

    // The pane closes on a click anywhere else, and a
    // measurement that went with it would be worth taking twice,
    // so the reading outlives the surface that asked for it.
    readonly property string words: {
        if (root.running) return root.busyWords;
        if (!root.measured) return root.idleWords;
        return Qt.formatDateTime(root.takenAt, "HH:mm");
    }

    readonly property string downText: root.reading(root.down)
    readonly property string upText: root.reading(root.up)

    function reading(value: string): string {
        if (value === "") return root.missingText;
        return `${value} ${root.unit}`;
    }

    function absorb(payload: string): void {
        for (const line of payload.trim().split("\n")) {
            const [key, value] = line.split("=");
            if (value === undefined) continue;
            if (key.trim() === "down") root.down = value.trim();
            if (key.trim() === "up") root.up = value.trim();
        }
        root.takenAt = new Date();
    }

    function measure(): void {
        if (probe.running) return;
        probe.running = true;
    }

    Process {
        id: probe

        command: root.script

        stdout: StdioCollector {
            onStreamFinished: root.absorb(this.text)
        }
    }
}
