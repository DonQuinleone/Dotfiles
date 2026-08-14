pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland

Singleton {
    id: root

    readonly property int refreshIntervalMs: 2000

    function layoutOf(workspace): string {
        return workspace?.lastIpcObject?.tiledLayout ?? "";
    }

    // Refreshing before Hyprland finishes its own first fetch
    // aborts that fetch, leaving the monitor model permanently
    // empty, so wait for a monitor to appear before polling.
    Timer {
        running: Hyprland.monitors.values.length > 0
        repeat: true
        interval: root.refreshIntervalMs

        onTriggered: Hyprland.refreshWorkspaces()
    }
}
