pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property int grabSettleMs: 250

    property bool shown: false
    property real closedAtMs: 0

    function toggle(): void {
        if (Date.now() - root.closedAtMs < root.grabSettleMs) return;
        root.shown = !root.shown;
    }

    function show(): void {
        root.shown = true;
    }

    function hide(): void {
        root.shown = false;
        root.closedAtMs = Date.now();
    }
}
