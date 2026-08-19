pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // The script owns the microphone and answers every verb with
    // the state it reached, so the bar never keeps a second copy
    // of whether TeamSpeak can hear the room.
    readonly property var script: [Preferences.donbox, "ptt"]

    readonly property var verbs: ({
        read: ["status"],
        toggle: ["toggle"]
    })

    readonly property string closedWord: "off"
    readonly property string latchedWord: "latched"
    readonly property string glyph: "󰍬"

    readonly property string statePath:
        `${Preferences.stateHome}/donbox/ptt`

    property string phase: root.closedWord

    readonly property bool live: root.phase !== root.closedWord
    readonly property bool latched: root.phase === root.latchedWord

    function absorb(payload: string): void {
        root.phase = payload.trim() || root.closedWord;
    }

    function refresh(): void {
        if (status.running) return;
        status.running = true;
    }

    function toggle(): void {
        if (command.running) return;
        command.running = true;
    }

    Component.onCompleted: root.refresh()

    Process {
        id: status

        command: root.script.concat(root.verbs.read)

        stdout: StdioCollector {
            onStreamFinished: root.absorb(this.text)
        }
    }

    Process {
        id: command

        command: root.script.concat(root.verbs.toggle)

        stdout: StdioCollector {
            onStreamFinished: root.absorb(this.text)
        }
    }

    // The key is bound in Hyprland, not here, so the bar learns
    // about a press the same way it learns about anything else
    // that moved the microphone.
    FileView {
        id: state

        path: root.statePath
        watchChanges: true
        printErrors: false

        onFileChanged: this.reload()
        onLoaded: root.absorb(this.text())
    }
}
