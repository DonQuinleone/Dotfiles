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

    // A workspace reports the layout its tiles are arranged by
    // even when the window in front of them is floating, so the
    // focused window is asked instead.
    function floatingOn(workspaceName: string): bool {
        const focused = Hyprland.activeToplevel?.lastIpcObject ?? null;
        if (!focused) return false;
        if (focused.workspace?.name !== workspaceName) return false;
        return focused.floating === true;
    }

    // Refreshing before Hyprland finishes its own first fetch
    // aborts that fetch, leaving the monitor model permanently
    // empty, so wait for a monitor to appear before polling.
    Timer {
        running: Hyprland.monitors.values.length > 0
        repeat: true
        interval: root.refreshIntervalMs

        onTriggered: {
            Hyprland.refreshWorkspaces();
            Hyprland.refreshToplevels();
        }
    }
}
