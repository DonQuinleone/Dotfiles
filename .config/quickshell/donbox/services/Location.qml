pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Kept in state rather than configuration: coordinates
// say where somebody lives.
Singleton {
    id: root

    readonly property int mostResults: 5
    readonly property int settleMs: 400
    readonly property int saveDelayMs: 1000
    readonly property int timeoutSeconds: 10
    readonly property int latitudeLimit: 90
    readonly property int longitudeLimit: 180

    readonly property string searchApi:
        "https://geocoding-api.open-meteo.com/v1/search"

    readonly property string stateHome:
        Quickshell.env("XDG_STATE_HOME")
        ?? `${Quickshell.env("HOME")}/.local/state`

    readonly property string directory: `${root.stateHome}/donbox`
    readonly property string path: `${root.directory}/location.json`

    property var place: null
    property var results: []
    property bool searching: false

    readonly property bool known: root.place !== null

    function describe(found: var): string {
        return [found.name, found.admin1, found.country]
            .filter(part => part)
            .join(", ");
    }

    function coordinates(query: string): var {
        const parts = query.split(",").map(part => part.trim());
        if (parts.length !== 2) return null;
        const latitude = Number(parts[0]);
        const longitude = Number(parts[1]);
        if (!isFinite(latitude) || !isFinite(longitude)) return null;
        if (Math.abs(latitude) > root.latitudeLimit) return null;
        if (Math.abs(longitude) > root.longitudeLimit) return null;
        return {
            name: `${latitude}, ${longitude}`,
            latitude: latitude,
            longitude: longitude
        };
    }

    function settle(query: string): void {
        finder.wanted = query.trim();
        root.results = [];
        hold.restart();
    }

    function search(): void {
        if (finder.wanted === "" || finder.running) return;
        const asked = encodeURIComponent(finder.wanted);
        finder.command = ["curl", "-fsS", "--max-time",
            `${root.timeoutSeconds}`,
            `${root.searchApi}?count=${root.mostResults}`
            + `&language=en&format=json&name=${asked}`];
        root.searching = true;
        finder.running = true;
    }

    function absorb(payload: string): void {
        root.searching = false;
        try {
            const found = JSON.parse(payload).results ?? [];
            root.results = found.map(item => ({
                name: root.describe(item),
                latitude: item.latitude,
                longitude: item.longitude
            }));
        } catch (error) {
            root.results = [];
        }
    }

    function choose(found: var): void {
        root.place = found;
        root.results = [];
    }

    function forget(): void {
        root.place = null;
        root.results = [];
    }

    function reparse(): void {
        try {
            const saved = JSON.parse(file.text());
            root.place = saved.place ?? null;
        } catch (error) {
            root.place = null;
        }
    }

    function save(): void {
        file.setText(JSON.stringify({ place: root.place }));
    }

    onPlaceChanged: writeBack.restart()

    Component.onCompleted: {
        Quickshell.execDetached(["mkdir", "-p", root.directory]);
        root.reparse();
    }

    Timer {
        id: hold

        interval: root.settleMs

        onTriggered: root.search()
    }

    Timer {
        id: writeBack

        interval: root.saveDelayMs

        onTriggered: root.save()
    }

    Process {
        id: finder

        property string wanted: ""

        stdout: StdioCollector {
            onStreamFinished: root.absorb(this.text)
        }

        onExited: root.searching = false
    }

    FileView {
        id: file

        path: root.path
        blockLoading: true
        atomicWrites: true
        printErrors: false
    }
}
