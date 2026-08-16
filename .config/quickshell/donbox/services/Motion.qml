pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // The motion script owns the compositor's animation state,
    // so the desktop reads and writes it rather than keeping a
    // second copy of the same settings.
    readonly property var verbs: ({
        read: ["get"],
        scale: ["set", "scale"],
        drift: ["set", "drift"],
        reduced: ["reduced"]
    })

    readonly property var switches: ({ on: "on", off: "off" })
    readonly property var affirmatives: ["on", "yes", "true"]

    readonly property var speeds: [
        { scale: 0.5, word: qsTr("Fast") },
        { scale: 0.75, word: qsTr("Brisk") },
        { scale: 1.0, word: qsTr("Normal") },
        { scale: 1.5, word: qsTr("Gentle") },
        { scale: 2.0, word: qsTr("Slow") }
    ]

    readonly property real neutralScale: 1.0
    readonly property int scaleDigits: 2

    readonly property var script: [Preferences.donbox, "motion"]

    property real scale: root.neutralScale
    property bool drift: false
    property bool reduced: false
    property bool available: false
    property string message: ""

    function truthy(value: string): bool {
        return root.affirmatives.indexOf(value) >= 0;
    }

    function absorb(payload: string): void {
        const state = ({});
        for (const line of payload.trim().split("\n")) {
            const [key, value] = line.split("=");
            if (value === undefined) continue;
            state[key.trim()] = value.trim();
        }
        if (state.scale === undefined) return;
        root.scale = Number(state.scale);
        root.drift = root.truthy(state.drift);
        root.reduced = root.truthy(state.reduced);
        root.available = true;
    }

    function run(args: var): void {
        if (command.running) return;
        root.message = "";
        command.command = root.script.concat(args);
        command.running = true;
    }

    function setScale(wanted: real): void {
        root.run(root.verbs.scale
            .concat([wanted.toFixed(root.scaleDigits)]));
    }

    function setDrift(wanted: bool): void {
        root.run(root.verbs.drift.concat([root.word(wanted)]));
    }

    function setReduced(wanted: bool): void {
        root.run(root.verbs.reduced.concat([root.word(wanted)]));
    }

    function word(wanted: bool): string {
        return wanted ? root.switches.on : root.switches.off;
    }

    function refresh(): void {
        if (status.running) return;
        status.running = true;
    }

    Component.onCompleted: root.refresh()

    Process {
        id: status

        command: root.script.concat(root.verbs.read)

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

        stderr: StdioCollector {
            onStreamFinished: root.message = this.text.trim()
        }

        onExited: root.refresh()
    }
}
