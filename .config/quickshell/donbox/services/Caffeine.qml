pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // The command owns the inhibitor, and both verbs answer with
    // the state they reached, so the desktop never keeps a second
    // copy of whether the session is being held awake.
    readonly property var script: [Preferences.donbox, "caffeine"]

    readonly property var verbs: ({
        read: ["status"],
        toggle: ["toggle"]
    })

    readonly property string awakeWord: "on"
    readonly property string glyph: ""

    readonly property string statePath:
        `${Preferences.stateHome}/donbox/caffeine`

    property bool active: false
    property bool available: false

    function absorb(payload: string): void {
        root.active = payload.trim() === root.awakeWord;
        root.available = true;
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

        onExited: code => {
            if (code === 0) return;
            root.available = false;
        }
    }

    Process {
        id: command

        command: root.script.concat(root.verbs.toggle)

        stdout: StdioCollector {
            onStreamFinished: root.absorb(this.text)
        }
    }

    // Caffeine is as often turned on from a terminal as from the
    // pane, and a bar that only learns about its own clicks would
    // be lying the rest of the time.
    FileView {
        id: state

        path: root.statePath
        watchChanges: true
        printErrors: false

        onFileChanged: this.reload()
        onLoaded: root.absorb(this.text())
    }
}
