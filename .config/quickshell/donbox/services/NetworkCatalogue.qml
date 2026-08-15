pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property int refreshMs: 8000
    readonly property int columnsExpected: 6
    readonly property real fullStrength: 1

    readonly property var shownFields:
        ["NAME", "UUID", "TYPE", "DEVICE", "ACTIVE", "TIMESTAMP"]

    readonly property var kinds: ({
        "802-11-wireless": {
            words: "Wi-Fi",
            glyph: Connectivity.glyphFor(root.fullStrength)
        },
        "802-3-ethernet": {
            words: "Wired",
            glyph: Connectivity.wiredGlyph
        }
    })

    property bool watching: false
    property string joining: ""
    property var saved: []

    readonly property bool busy: root.joining !== ""

    function wordsFor(kind: string): string {
        return root.kinds[kind]?.words ?? "";
    }

    function glyphFor(kind: string): string {
        return root.kinds[kind]?.glyph ?? "";
    }

    function keeps(kind: string): bool {
        return root.kinds[kind] !== undefined;
    }

    function entryFrom(columns: var): var {
        return {
            name: columns[0],
            uuid: columns[1],
            kind: columns[2],
            device: columns[3],
            active: columns[4] === "yes",
            lastUsed: Number(columns[5])
        };
    }

    function ranked(first: var, second: var): int {
        return Number(second.active) - Number(first.active)
            || second.lastUsed - first.lastUsed
            || first.name.localeCompare(second.name);
    }

    function statusOf(entry: var): string {
        if (entry.active) return "Connected";
        return root.wordsFor(entry.kind);
    }

    function absorb(payload: string): void {
        root.saved = NetworkCli.rowsIn(payload)
            .filter(columns => columns.length >= root.columnsExpected)
            .map(columns => root.entryFrom(columns))
            .filter(entry => root.keeps(entry.kind))
            .sort(root.ranked);
    }

    function refresh(): void {
        if (reader.running) return;
        reader.running = true;
    }

    function activate(entry: var): void {
        if (root.busy || entry.active) return;
        root.joining = entry.uuid;
        joiner.command =
            ["nmcli", "connection", "up", "uuid", entry.uuid];
        joiner.running = true;
    }

    onWatchingChanged: if (root.watching) root.refresh()

    Timer {
        running: root.watching
        repeat: true
        interval: root.refreshMs

        onTriggered: root.refresh()
    }

    Process {
        id: reader

        command: ["nmcli", "-t", "-f",
            root.shownFields.join(","), "connection", "show"]

        stdout: StdioCollector {
            onStreamFinished: root.absorb(this.text)
        }
    }

    Process {
        id: joiner

        onExited: code => {
            root.joining = "";
            root.refresh();
            NetworkLink.refresh();
            if (code !== 0) {
                console.error("donbox: nmcli could not join that "
                    + "saved network");
            }
        }
    }
}
