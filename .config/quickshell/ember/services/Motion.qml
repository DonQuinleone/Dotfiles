pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // The motion script owns the compositor's animation state,
    // so the desktop asks it rather than writing its own.
    readonly property var verbs: ({
        read: "status",
        speed: "speed",
        reduce: "reduce"
    })

    readonly property var switches: ({
        on: "on",
        off: "off"
    })

    readonly property var speeds: [
        { scale: 0.5, word: qsTr("Fast") },
        { scale: 0.75, word: qsTr("Brisk") },
        { scale: 1.0, word: qsTr("Normal") },
        { scale: 1.5, word: qsTr("Gentle") },
        { scale: 2.0, word: qsTr("Slow") }
    ]

    readonly property real neutralScale: 1.0

    readonly property string script:
        `${Preferences.configHome}/hypr/scripts/motion`

    property real scale: root.neutralScale
    property bool reduced: false
    property bool available: false

    function absorb(payload: string): void {
        try {
            const state = JSON.parse(payload);
            root.scale = state.scale ?? root.neutralScale;
            root.reduced = state.reduced ?? false;
            root.available = true;
        } catch (error) {
            root.available = false;
        }
    }

    function run(args: var): void {
        if (command.running) return;
        command.command = [root.script].concat(args);
        command.running = true;
    }

    function setScale(wanted: real): void {
        root.scale = wanted;
        root.run([root.verbs.speed, `${wanted}`]);
    }

    function setReduced(wanted: bool): void {
        root.reduced = wanted;
        root.run([root.verbs.reduce,
            wanted ? root.switches.on : root.switches.off]);
    }

    function refresh(): void {
        if (status.running) return;
        status.running = true;
    }

    Component.onCompleted: root.refresh()

    Process {
        id: status

        command: [root.script, root.verbs.read]

        stdout: StdioCollector {
            onStreamFinished: root.absorb(this.text)
        }

        onExited: code => {
            if (code === 0) return;
            root.available = false;
        }
    }

    Process {
        id: command

        onExited: root.refresh()
    }
}
