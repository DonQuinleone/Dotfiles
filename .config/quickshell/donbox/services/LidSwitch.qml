pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string inhibitorWho: "hypr-lid"
    readonly property string lidSwitchWhat: "handle-lid-switch"

    readonly property string script:
        `${Preferences.configHome}/hypr/scripts/lid`

    property bool held: false

    function absorb(payload: string): void {
        root.held = payload.split("\n").some(line =>
            line.indexOf(root.lidSwitchWhat) >= 0
            && line.indexOf(root.inhibitorWho) >= 0);
    }

    function refresh(): void {
        if (probe.running) return;
        probe.running = true;
    }

    function sync(): void {
        if (matcher.running) return;
        matcher.running = true;
    }

    Component.onCompleted: root.refresh()

    Process {
        id: probe

        command: ["systemd-inhibit", "--list", "--no-legend"]

        stdout: StdioCollector {
            onStreamFinished: root.absorb(this.text)
        }
    }

    Process {
        id: matcher

        command: [root.script, "sync"]

        onExited: root.refresh()
    }
}
