pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property var modifiers: [
        { mask: 64, word: qsTr("Super") },
        { mask: 8, word: qsTr("Alt") },
        { mask: 4, word: qsTr("Ctrl") },
        { mask: 1, word: qsTr("Shift") }
    ]

    readonly property string bareGroup: qsTr("Media and laptop keys")

    readonly property var keyNames: ({
        "Return": qsTr("Enter"),
        "space": qsTr("Space"),
        "Escape": qsTr("Esc"),
        "equal": "=",
        "minus": "-",
        "backslash": "\\",
        "comma": ",",
        "period": ".",
        "Print": qsTr("Print screen"),
        "mouse_up": qsTr("Wheel up"),
        "mouse_down": qsTr("Wheel down"),
        "mouse:272": qsTr("Left button"),
        "mouse:273": qsTr("Right button"),
        "XF86AudioRaiseVolume": qsTr("Volume up"),
        "XF86AudioLowerVolume": qsTr("Volume down"),
        "XF86AudioMute": qsTr("Mute"),
        "XF86AudioMicMute": qsTr("Mute microphone"),
        "XF86AudioPlay": qsTr("Play"),
        "XF86AudioPause": qsTr("Pause"),
        "XF86AudioNext": qsTr("Next track"),
        "XF86AudioPrev": qsTr("Previous track"),
        "XF86MonBrightnessUp": qsTr("Brightness up"),
        "XF86MonBrightnessDown": qsTr("Brightness down")
    })

    readonly property var flagWords: [
        { field: "repeat", word: qsTr("repeats while held") },
        { field: "locked", word: qsTr("works when locked") },
        { field: "release", word: qsTr("on release") },
        { field: "longPress", word: qsTr("long press") }
    ]

    property var entries: []

    readonly property var groups: root.gathered()

    function words(mask: int): var {
        return root.modifiers
            .filter(entry => (mask & entry.mask) !== 0)
            .map(entry => entry.word);
    }

    function keyWord(key: string): string {
        return root.keyNames[key] ?? key;
    }

    function flags(bind: var): string {
        return root.flagWords
            .filter(entry => bind[entry.field])
            .map(entry => entry.word)
            .join(", ");
    }

    function groupOf(mask: int): string {
        const named = root.words(mask);
        return named.length > 0 ? named.join(" + ") : root.bareGroup;
    }

    function describe(bind: var): var {
        const group = root.groupOf(bind.modmask);
        const key = root.keyWord(bind.key);
        const named = root.words(bind.modmask).concat([key]);
        return {
            group: group,
            key: key,
            combo: named.join(" + "),
            description: bind.description ?? "",
            detail: root.flags(bind)
        };
    }

    function matches(entry: var, query: string): bool {
        if (query === "") return true;
        const haystack =
            `${entry.combo} ${entry.description} ${entry.group}`;
        return haystack.toLowerCase()
            .indexOf(query.toLowerCase().trim()) >= 0;
    }

    function filtered(query: string): var {
        return root.groups
            .map(group => ({
                name: group.name,
                rows: group.rows.filter(
                    entry => root.matches(entry, query))
            }))
            .filter(group => group.rows.length > 0);
    }

    function gathered(): var {
        const named = [];
        for (const bind of root.entries) {
            const entry = root.describe(bind);
            const group = named.find(item => item.name === entry.group);
            if (group) {
                group.rows.push(entry);
                continue;
            }
            named.push({ name: entry.group, rows: [entry] });
        }
        return named;
    }

    function absorb(payload: string): void {
        try {
            root.entries = JSON.parse(payload)
                .filter(bind => bind.submap === "");
        } catch (error) {
            console.error("ember: hyprctl gave no bindings:", error);
        }
    }

    function refresh(): void {
        if (probe.running) return;
        probe.running = true;
    }

    Component.onCompleted: root.refresh()

    Process {
        id: probe

        command: ["hyprctl", "-j", "binds"]

        stdout: StdioCollector {
            onStreamFinished: root.absorb(this.text)
        }
    }
}
