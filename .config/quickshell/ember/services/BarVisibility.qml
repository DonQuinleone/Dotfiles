pragma Singleton

import Quickshell
import Quickshell.Hyprland

Singleton {
    id: root

    property var hidden: ({})

    function isVisible(monitor: string): bool {
        return root.hidden[monitor] !== true;
    }

    function toggle(monitor: string): void {
        const next = Object.assign({}, root.hidden);
        next[monitor] = !next[monitor];
        root.hidden = next;
    }

    function toggleFocused(): void {
        const monitor = Hyprland.focusedMonitor;
        if (!monitor) return;
        root.toggle(monitor.name);
    }
}
