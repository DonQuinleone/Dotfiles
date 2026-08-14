pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property int pollIntervalMs: 500
    readonly property real neutralFactor: 1.0

    property real factor: root.neutralFactor

    readonly property bool magnified: root.factor > root.neutralFactor
    readonly property int percent: Math.round(root.factor * 100)

    function apply(payload: string): void {
        try {
            root.factor =
                JSON.parse(payload).float ?? root.neutralFactor;
        } catch (error) {
            root.factor = root.neutralFactor;
        }
    }

    Process {
        id: probe

        command: ["hyprctl", "-j", "getoption", "cursor:zoom_factor"]

        stdout: StdioCollector {
            onStreamFinished: root.apply(this.text)
        }
    }

    Timer {
        running: true
        repeat: true
        triggeredOnStart: true
        interval: root.pollIntervalMs

        onTriggered: if (!probe.running) probe.running = true
    }
}
