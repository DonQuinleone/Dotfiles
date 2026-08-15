pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

Singleton {
    id: root

    readonly property string script:
        `${Preferences.configHome}/hypr/scripts/monitor-profile`

    readonly property string matchedWord: "connected"
    readonly property string unmatchedWord: "-"
    readonly property int columnCount: 3

    property var profiles: []
    property string trouble: ""

    readonly property var matched:
        root.profiles.find(profile => profile.matched) ?? null

    readonly property string matchedName: root.matched?.name ?? ""

    readonly property bool detecting: detection.running

    function refresh(): void {
        if (listing.running) return;
        listing.running = true;
    }

    function detect(): void {
        if (detection.running) return;
        root.trouble = "";
        detection.running = true;
    }

    // Whether a profile fits the screens plugged in now is
    // settled by description matching inside the script, so its
    // own status column is read back rather than a second rule
    // here that could disagree with it.
    function listed(fields: var): bool {
        if (fields.length !== root.columnCount) return false;
        return fields[2] === root.matchedWord
            || fields[2] === root.unmatchedWord;
    }

    function absorb(payload: string): void {
        root.profiles = payload.split("\n")
            .map(line => line.trim().split(/\s+/))
            .filter(fields => root.listed(fields))
            .map(fields => ({
                name: fields[0],
                outputs: Number(fields[1]),
                matched: fields[2] === root.matchedWord
            }));
    }

    Component.onCompleted: root.refresh()

    Process {
        id: listing

        command: [root.script, "list"]

        stdout: StdioCollector {
            onStreamFinished: root.absorb(this.text)
        }
    }

    Process {
        id: detection

        command: [root.script, "detect"]

        onExited: {
            Hyprland.refreshMonitors();
            root.refresh();
        }

        stderr: StdioCollector {
            onStreamFinished: root.trouble = this.text.trim()
        }
    }
}
