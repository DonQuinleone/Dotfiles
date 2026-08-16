pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    // Dismissing a pane by clicking away also lands the click on
    // the pill that opened it, which would reopen it on the way
    // back up.
    readonly property int grabSettleMs: 250
    readonly property string none: ""

    // One name rather than a visible flag on every surface, so
    // one pane closing another is what the state is, not
    // something each pane has to arrange with its neighbours.
    property string open: root.none

    property real closedAtMs: 0

    // Set by PaneKeys, and read by every grab so that the
    // surface holding the keyboard counts as part of the pane.
    property var keySurface: null

    function isOpen(name: string): bool {
        return name !== root.none && root.open === name;
    }

    function show(name: string): void {
        root.open = name;
    }

    function close(): void {
        if (root.open === root.none) return;
        root.open = root.none;
        root.closedAtMs = Date.now();
    }

    function toggle(name: string): void {
        if (root.isOpen(name)) {
            root.close();
            return;
        }
        if (Date.now() - root.closedAtMs < root.grabSettleMs) return;
        root.show(name);
    }
}
