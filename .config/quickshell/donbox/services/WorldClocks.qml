pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property int sampleMs: 30000
    readonly property int saveDelayMs: 1000
    readonly property string regionSeparator: "/"
    readonly property string readingSeparator: " "

    readonly property string glyph: "󰖟"

    // date is the only thing here that knows the zone rules, so
    // every reading is asked of it rather than worked out from a
    // remembered offset that daylight saving would invalidate.
    readonly property string sampleScript:
        'for zone in "$@"; do echo "$zone $(TZ="$zone" date +%H:%M)"'
        + '; done'

    readonly property string stateHome:
        Quickshell.env("XDG_STATE_HOME")
        ?? `${Quickshell.env("HOME")}/.local/state`

    readonly property string directory: `${root.stateHome}/donbox`
    readonly property string path: `${root.directory}/clocks.json`

    property bool watching: false
    property var chosen: []
    property var available: []
    property var readings: ({})

    readonly property bool ready:
        root.watching && root.chosen.length > 0

    readonly property var regions: root.available
        .map(zone => zone.split(root.regionSeparator)[0])
        .filter((name, place, all) => all.indexOf(name) === place)
        .sort()

    // The database also carries single-word legacy names such as
    // GB and Zulu, which have no region to file them under.
    function grouped(zone: string): bool {
        return zone.includes(root.regionSeparator);
    }

    function labelOf(zone: string): string {
        const parts = zone.split(root.regionSeparator);
        return parts[parts.length - 1].split("_").join(" ");
    }

    function timeOf(zone: string): string {
        return root.readings[zone] ?? "";
    }

    function citiesIn(region: string): var {
        return root.available.filter(zone =>
            zone.startsWith(`${region}${root.regionSeparator}`));
    }

    function holds(zone: string): bool {
        return root.chosen.includes(zone);
    }

    function add(zone: string): void {
        if (root.holds(zone)) return;
        root.chosen = root.chosen.concat([zone]);
        root.sample();
    }

    function remove(zone: string): void {
        root.chosen = root.chosen.filter(item => item !== zone);
    }

    function absorb(payload: string): void {
        const found = ({});
        for (const line of payload.split("\n")) {
            const mark = line.indexOf(root.readingSeparator);
            if (mark < 0) continue;
            found[line.slice(0, mark)] = line.slice(mark + 1);
        }
        root.readings = found;
    }

    function sample(): void {
        if (reader.running || root.chosen.length === 0) return;
        reader.command = ["sh", "-c", root.sampleScript, "sh"]
            .concat(root.chosen);
        reader.running = true;
    }

    function listZones(): void {
        if (root.available.length > 0 || zoneReader.running) return;
        zoneReader.running = true;
    }

    function reparse(): void {
        try {
            const saved = JSON.parse(file.text());
            root.chosen = saved.zones ?? [];
        } catch (error) {
            root.chosen = [];
        }
    }

    function save(): void {
        file.setText(JSON.stringify({ zones: root.chosen }));
    }

    onChosenChanged: writeBack.restart()
    onReadyChanged: if (root.ready) root.sample()

    Component.onCompleted: {
        Quickshell.execDetached(["mkdir", "-p", root.directory]);
        root.reparse();
    }

    Timer {
        running: root.ready
        repeat: true
        interval: root.sampleMs

        onTriggered: root.sample()
    }

    Timer {
        id: writeBack

        interval: root.saveDelayMs

        onTriggered: root.save()
    }

    Process {
        id: reader

        stdout: StdioCollector {
            onStreamFinished: root.absorb(this.text)
        }
    }

    Process {
        id: zoneReader

        command: ["timedatectl", "list-timezones"]

        stdout: StdioCollector {
            onStreamFinished: root.available = this.text
                .split("\n")
                .filter(line => root.grouped(line))
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
