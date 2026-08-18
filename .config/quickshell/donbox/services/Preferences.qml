pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property int writeDelayMs: 300
    readonly property int jsonIndent: 4
    readonly property string fallbackCursorTheme: "Adwaita"

    readonly property var defaults: ({
        zoomStep: 1.0,
        detachedCamera: false,
        cursorSize: 48,
        borderSize: 4,
        screensaver: "cycle",
        primaryMonitor: "",
        devices: ({})
    })

    readonly property var luaKeys: ({
        zoomStep: "zoom_step",
        detachedCamera: "zoom_detached_camera",
        cursorSize: "cursor_size",
        borderSize: "border_size"
    })

    readonly property var deviceKeys: ({
        sensitivity: "sensitivity",
        naturalScroll: "natural_scroll",
        tapToClick: "tap_to_click",
        scrollFactor: "scroll_factor"
    })

    readonly property string configHome:
        Quickshell.env("XDG_CONFIG_HOME")
        ?? `${Quickshell.env("HOME")}/.config`

    readonly property string stateHome:
        Quickshell.env("XDG_STATE_HOME")
        ?? `${Quickshell.env("HOME")}/.local/state`

    // The router rather than PATH: the session the shell starts
    // in does not always carry ~/.local/bin.
    readonly property string donbox:
        `${Quickshell.env("HOME")}/.local/bin/donbox`

    readonly property string cursorTheme:
        Quickshell.env("XCURSOR_THEME") ?? root.fallbackCursorTheme

    readonly property string path:
        `${root.configHome}/quickshell/settings.json`

    readonly property string stateDirectory: `${root.stateHome}/hypr`

    readonly property string generated:
        `${root.stateDirectory}/settings.lua`

    readonly property string applier:
        `${root.configHome}/hypr/lua/overrides.lua`

    property var data: ({})
    property var seeds: ({})
    property bool ready: false

    function value(name: string): var {
        const saved = root.data[name];
        if (saved !== undefined) return saved;
        const seeded = root.seeds[name];
        return seeded !== undefined ? seeded : root.defaults[name];
    }

    function set(name: string, updated: var): void {
        const next = Object.assign({}, root.data);
        next[name] = updated;
        root.data = next;
    }

    function deviceValue(device: string, name: string,
        fallback: var): var {
        const saved = root.value("devices")[device]?.[name];
        return saved !== undefined ? saved : fallback;
    }

    function setDevice(device: string, name: string,
        updated: var): void {
        const devices = Object.assign({}, root.value("devices"));
        const entry = Object.assign({}, devices[device] ?? ({}));
        entry[name] = updated;
        devices[device] = entry;
        root.set("devices", devices);
    }

    function forgetDevice(device: string): void {
        const devices = Object.assign({}, root.value("devices"));
        delete devices[device];
        root.set("devices", devices);
    }

    function deviceRows(): var {
        const devices = root.value("devices");
        return Object.keys(devices).map(device => {
            const row = { name: device };
            for (const name in root.deviceKeys) {
                if (devices[device][name] === undefined) continue;
                row[root.deviceKeys[name]] = devices[device][name];
            }
            return row;
        });
    }

    function payload(): var {
        const table = ({});
        for (const name in root.luaKeys) {
            table[root.luaKeys[name]] = root.value(name);
        }
        table.devices = root.deviceRows();
        return table;
    }

    function applyOverrides(): void {
        const table = LuaTable.table(root.payload());
        generatedFile.setText(`return ${table}\n`);
        live.command = ["hyprctl", "eval",
            `dofile(${LuaTable.quoted(root.applier)}).apply(${table})`];
        live.running = true;
    }

    function resizeCursor(): void {
        if (cursor.running) return;
        cursor.command = ["hyprctl", "setcursor", root.cursorTheme,
            `${root.value("cursorSize")}`];
        cursor.running = true;
    }

    function sync(): void {
        if (live.running) {
            writeBack.restart();
            return;
        }
        root.applyOverrides();
        root.resizeCursor();
    }

    function effective(): var {
        const complete = ({});
        for (const name in root.defaults) {
            complete[name] = root.value(name);
        }
        return complete;
    }

    function materialise(): void {
        root.data = root.effective();
    }

    function serialised(): string {
        return JSON.stringify(root.data, null, root.jsonIndent);
    }

    function seed(name: string, seeded: var): void {
        const next = Object.assign({}, root.seeds);
        next[name] = seeded;
        root.seeds = next;
    }

    function reparse(): void {
        try {
            root.data = JSON.parse(file.text());
        } catch (error) {
            root.data = ({});
        }
    }

    // Reading a hand-edited file must not restart the write
    // back, which would reformat the file under an editor still
    // holding it open.
    function adopt(): void {
        if (!root.ready) return;
        if (file.text() === root.serialised()) return;
        root.ready = false;
        root.reparse();
        root.ready = true;
        root.sync();
    }

    onDataChanged: {
        if (!root.ready) return;
        writeBack.restart();
    }

    Component.onCompleted: {
        Quickshell.execDetached(
            ["mkdir", "-p", root.stateDirectory]);
        root.reparse();
        root.ready = true;
        const inherited = Number(Quickshell.env("XCURSOR_SIZE"));
        if (inherited > 0) root.seed("cursorSize", inherited);
        root.materialise();
    }

    Timer {
        id: writeBack

        interval: root.writeDelayMs

        onTriggered: {
            file.setText(root.serialised());
            root.sync();
        }
    }

    Process {
        id: cursor
    }

    Process {
        id: live

        stderr: StdioCollector {
            onStreamFinished: {
                if (!this.text.trim()) return;
                console.error("donbox: hyprctl refused the settings:",
                    this.text.trim());
            }
        }
    }

    Process {
        id: borderProbe

        running: true
        command: ["hyprctl", "-j", "getoption", "general:border_size"]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.seed("borderSize", JSON.parse(this.text).int);
                } catch (error) {
                    return;
                }
            }
        }
    }

    FileView {
        id: file

        path: root.path
        blockLoading: true
        watchChanges: true
        atomicWrites: true
        printErrors: false

        onFileChanged: this.reload()
        onLoaded: root.adopt()
    }

    FileView {
        id: generatedFile

        path: root.generated
        atomicWrites: true
        printErrors: false
    }
}
