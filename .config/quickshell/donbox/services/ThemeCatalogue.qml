pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property int markerWidth: 2
    readonly property string currentMarker: "*"

    readonly property string script:
        `${Preferences.configHome}/hypr/scripts/theme`

    readonly property string wallpaperRoot:
        `${Quickshell.env("HOME")}/Pictures/walls`

    property var themes: []
    property string active: ""
    property string message: ""

    readonly property bool busy: command.running

    readonly property url wallpapers:
        `file://${root.wallpaperRoot}/${root.active}`

    function parse(payload: string): void {
        root.themes = payload.split("\n")
            .filter(line => line.length > root.markerWidth)
            .map(line => root.entry(line));
        root.active =
            root.themes.find(theme => theme.current)?.slug ?? "";
    }

    function entry(line: string): var {
        const rest = line.slice(root.markerWidth).trim();
        const slug = rest.split(/\s+/)[0];
        const name = rest.slice(slug.length).trim();
        return {
            slug: slug,
            name: name === "" ? slug : name,
            current: line.charAt(0) === root.currentMarker
        };
    }

    function run(args: var): void {
        if (command.running) return;
        root.message = "";
        command.command = [root.script].concat(args);
        command.running = true;
    }

    function commit(slug: string): void {
        root.run(["set", slug]);
    }

    function applyAccent(name: string): void {
        root.run(["accent", name]);
    }

    function applyWallpaper(path: string): void {
        root.run(["wallpaper", path]);
    }

    function refresh(): void {
        if (listing.running) return;
        listing.running = true;
    }

    Component.onCompleted: root.refresh()

    Connections {
        target: Theme

        function onDataChanged(): void {
            root.refresh();
        }
    }

    Process {
        id: listing

        command: [root.script, "list"]

        stdout: StdioCollector {
            onStreamFinished: root.parse(this.text)
        }
    }

    Process {
        id: command

        onExited: root.refresh()

        stderr: StdioCollector {
            onStreamFinished: root.message = this.text.trim()
        }
    }
}
