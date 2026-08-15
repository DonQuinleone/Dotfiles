pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string entryGroup: "[Desktop Entry]"
    readonly property string hiddenKey: "Hidden"
    readonly property string fileMarker: "\u001e"
    readonly property string fallbackConfigDirectory: "/etc/xdg"
    readonly property string xdgTarget:
        "xdg-desktop-autostart.target"

    readonly property string commandsOpener: "local commands = {"
    readonly property string commandsCloser: "\n}"
    readonly property string luaComment: "--"
    readonly property string luaConcatenation: ".."
    readonly property string luaConfigTerm: "config"
    readonly property string luaQuote: "\""
    readonly property string luaSeparator: ","

    readonly property var stateWords: ({
        "active": qsTr("running"),
        "activating": qsTr("starting"),
        "deactivating": qsTr("stopping"),
        "inactive": qsTr("not running"),
        "failed": qsTr("failed")
    })

    readonly property string listScript:
        'set -eu; for dir in "$@"; do '
        + 'for file in "$dir"/*.desktop; do '
        + '[ -f "$file" ] || continue; '
        + 'printf "\\036%s\\n" "$file"; cat "$file"; '
        + 'printf "\\n"; done; done'

    readonly property string unitScript:
        "set -eu; systemctl --user list-unit-files "
        + "--state=enabled --no-legend --plain "
        + "| awk '{ print $1 }' "
        + "| xargs -r systemctl --user show "
        + "-p Id -p Description -p ActiveState -p ExecStart"

    readonly property string writeScript:
        'set -eu; mkdir -p "$(dirname "$1")"; '
        + 'printf "%s" "$2" >"$1"'

    readonly property string removeScript: 'set -eu; rm -f "$1"'

    readonly property string luaPath:
        `${Preferences.configHome}/hypr/lua/autostart.lua`

    readonly property string userDirectory:
        `${Preferences.configHome}/autostart`

    readonly property var configDirectories:
        (Quickshell.env("XDG_CONFIG_DIRS") ?? "")
            .split(":").filter(part => part !== "")

    readonly property var systemDirectories:
        root.configDirectories.length > 0
            ? root.configDirectories
            : [root.fallbackConfigDirectory]

    readonly property var searchPaths: [root.userDirectory]
        .concat(root.systemDirectories
            .map(base => `${base}/autostart`))

    readonly property var desktopNames:
        (Quickshell.env("XDG_CURRENT_DESKTOP") ?? "")
            .split(":").filter(part => part !== "")

    property var compositor: []
    property var entries: []
    property var units: []
    property bool xdgHonoured: false

    function stateWord(state: string): string {
        return root.stateWords[state] ?? state;
    }

    function commandBlock(text: string): string {
        const opened = text.indexOf(root.commandsOpener);
        if (opened < 0) return "";
        const from = opened + root.commandsOpener.length;
        const closed = text.indexOf(root.commandsCloser, from);
        if (closed < 0) return "";
        return text.slice(from, closed);
    }

    function stripped(block: string): string {
        return block.split("\n")
            .filter(line =>
                !line.trim().startsWith(root.luaComment))
            .join("\n");
    }

    function pieces(block: string): var {
        const found = [];
        let gathered = "";
        let quoted = false;
        for (let at = 0; at < block.length; at += 1) {
            const letter = block.charAt(at);
            if (letter === root.luaQuote) quoted = !quoted;
            if (letter === root.luaSeparator && !quoted) {
                found.push(gathered);
                gathered = "";
                continue;
            }
            gathered += letter;
        }
        found.push(gathered);
        return found.map(piece => piece.trim())
            .filter(piece => piece !== "");
    }

    function term(part: string): string {
        if (part.startsWith(root.luaQuote))
            return part.slice(1, -1);
        if (part === root.luaConfigTerm)
            return Preferences.configHome;
        return part;
    }

    function resolved(piece: string): string {
        return piece.split(root.luaConcatenation)
            .map(part => root.term(part.trim()))
            .join("");
    }

    function readCompositor(): void {
        const block = root.stripped(
            root.commandBlock(lua.text()));
        root.compositor = root.pieces(block)
            .map(piece => root.resolved(piece));
    }

    function shared(names: var): bool {
        return names.some(
            name => root.desktopNames.indexOf(name) >= 0);
    }

    function listedNames(value: string): var {
        return value.split(";").filter(part => part !== "");
    }

    function mismatch(fields: var): string {
        const only = root.listedNames(fields.OnlyShowIn ?? "");
        if (only.length > 0 && !root.shared(only))
            return qsTr("Set to start only in %1.")
                .arg(only.join(", "));
        const excluded = root.listedNames(fields.NotShowIn ?? "");
        if (root.shared(excluded))
            return qsTr("Set not to start in %1.")
                .arg(root.desktopNames.join(", "));
        return "";
    }

    function entryFrom(path: string, text: string): var {
        const fields = KeyValues.group(text, root.entryGroup);
        const id = path.slice(path.lastIndexOf("/") + 1);
        return ({
            id: id,
            path: path,
            text: text,
            name: fields.Name ?? id,
            command: fields.Exec ?? "",
            hidden: KeyValues.truthy(fields.Hidden ?? ""),
            reason: root.mismatch(fields),
            userOwned: path.startsWith(root.userDirectory),
            systemBacked: false
        });
    }

    function byName(first: var, second: var): int {
        const left = first.name.toLowerCase();
        const right = second.name.toLowerCase();
        if (left === right) return 0;
        return left < right ? -1 : 1;
    }

    function absorbEntries(payload: string): void {
        const found = [];
        for (const chunk of payload.split(root.fileMarker)) {
            const split = chunk.indexOf("\n");
            if (split < 0) continue;
            const entry = root.entryFrom(chunk.slice(0, split),
                chunk.slice(split + 1));
            const seen = found.find(item => item.id === entry.id);
            if (seen) {
                seen.systemBacked = true;
                continue;
            }
            found.push(entry);
        }
        root.entries = found.sort(
            (first, second) => root.byName(first, second));
    }

    function commandOf(value: string): string {
        const found = /argv\[\]=([^;]*)/.exec(value);
        return found ? found[1].trim() : "";
    }

    function unitFrom(record: string): var {
        const fields = KeyValues.pairs(record);
        return ({
            id: fields.Id ?? "",
            name: fields.Description ?? "",
            command: root.commandOf(fields.ExecStart ?? ""),
            state: fields.ActiveState ?? ""
        });
    }

    function absorbUnits(payload: string): void {
        root.units = payload.split("\n\n")
            .map(record => root.unitFrom(record))
            .filter(unit => unit.id !== "");
    }

    function pathOf(id: string): string {
        return `${root.userDirectory}/${id}`;
    }

    function edit(command: var): void {
        if (editor.running) return;
        editor.command = command;
        editor.running = true;
    }

    function setHidden(id: string, hidden: bool): void {
        const entry = root.entries.find(item => item.id === id);
        if (!entry) return;
        const written = KeyValues.replaced(entry.text,
            root.entryGroup, root.hiddenKey, `${hidden}`);
        root.edit(["sh", "-c", root.writeScript, "sh",
            root.pathOf(id), written]);
    }

    function useSystemCopy(id: string): void {
        root.edit(["sh", "-c", root.removeScript, "sh",
            root.pathOf(id)]);
    }

    function start(probe: var): void {
        if (probe.running) return;
        probe.running = true;
    }

    function refresh(): void {
        root.start(entryProbe);
        root.start(unitProbe);
        root.start(targetProbe);
        lua.reload();
    }

    Component.onCompleted: root.refresh()

    Process {
        id: entryProbe

        command: ["sh", "-c", root.listScript, "sh"]
            .concat(root.searchPaths)

        stdout: StdioCollector {
            onStreamFinished: root.absorbEntries(this.text)
        }
    }

    Process {
        id: unitProbe

        command: ["sh", "-c", root.unitScript]

        stdout: StdioCollector {
            onStreamFinished: root.absorbUnits(this.text)
        }
    }

    Process {
        id: targetProbe

        command: ["systemctl", "--user", "is-active", "--quiet",
            root.xdgTarget]

        onExited: code => root.xdgHonoured = code === 0
    }

    Process {
        id: editor

        onExited: root.refresh()

        stderr: StdioCollector {
            onStreamFinished: {
                if (!this.text.trim()) return;
                console.error(
                    "donbox: cannot write the autostart entry:",
                    this.text.trim());
            }
        }
    }

    FileView {
        id: lua

        path: root.luaPath
        blockLoading: true
        watchChanges: true
        printErrors: false

        onFileChanged: this.reload()
        onLoaded: root.readCompositor()
    }
}
