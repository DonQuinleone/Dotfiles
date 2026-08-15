pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property int maxAncestry: 4
    readonly property int initPid: 1
    readonly property int parentStatField: 1

    readonly property var relays:
        ["notify-send", "notify", "gdbus", "dbus-send"]

    readonly property var shells:
        ["bash", "sh", "zsh", "fish", "dash", "ksh"]

    function anonymous(name: var): bool {
        return root.relays.indexOf(name) >= 0
            || root.shells.indexOf(name) >= 0;
    }

    function slurp(path: string): string {
        const view = reader.createObject(root, { path: path });
        const contents = view.text();
        view.destroy();
        return contents;
    }

    function leaf(path: string): string {
        return path.slice(path.lastIndexOf("/") + 1);
    }

    function parentOf(pid: int): int {
        const stat = root.slurp(`/proc/${pid}/stat`);
        const tail = stat.slice(stat.lastIndexOf(")") + 1).trim();
        return Number(tail.split(" ")[root.parentStatField] ?? 0);
    }

    function commandOf(pid: int): string {
        const words = root.slurp(`/proc/${pid}/cmdline`)
            .split("\0").filter(word => word !== "");
        if (words.length === 0) return "";
        const program = root.leaf(words[0]);
        if (root.shells.indexOf(program) < 0) return program;
        const script = words.slice(1)
            .find(word => !word.startsWith("-"));
        return script ? root.leaf(script) : program;
    }

    function nameFor(pid: var): string {
        let current = Number(pid ?? 0);
        for (let step = 0; step < root.maxAncestry; step++) {
            if (current <= root.initPid) return "";
            const name = root.commandOf(current);
            if (name && !root.anonymous(name)) return name;
            current = root.parentOf(current);
        }
        return "";
    }

    Component {
        id: reader

        FileView {
            blockLoading: true
            printErrors: false
        }
    }
}
