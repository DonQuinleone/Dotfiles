pragma Singleton

import Quickshell

Singleton {
    id: root

    readonly property string configured:
        Preferences.value("primaryMonitor") ?? ""

    // Falling back to the largest panel rather than the first
    // keeps the choice on the screen the desk is built around
    // when the dock renumbers its connectors.
    readonly property string name: {
        const screens = Quickshell.screens ?? [];
        if (screens.length === 0) return "";

        for (const screen of screens) {
            if (screen.name === root.configured) return screen.name;
        }

        let best = screens[0];
        for (const screen of screens) {
            if (screen.width * screen.height
                > best.width * best.height) {
                best = screen;
            }
        }
        return best.name;
    }

    function isPrimary(monitor: string): bool {
        return monitor !== "" && monitor === root.name;
    }
}
