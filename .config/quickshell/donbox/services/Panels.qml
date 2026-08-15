pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    // Dismissing a panel by clicking away also lands the click on
    // the pill that opened it, which would reopen it on the way
    // back up.
    readonly property int grabSettleMs: 250

    property real closedAtMs: 0

    signal requested(name: string)

    function toggle(name: string): void {
        if (Date.now() - root.closedAtMs < root.grabSettleMs) return;
        root.requested(name);
    }

    function noteClosed(): void {
        root.closedAtMs = Date.now();
    }
}
