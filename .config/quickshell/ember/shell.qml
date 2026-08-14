import Quickshell
import Quickshell.Io
import qs.services
import qs.ui

ShellRoot {
    Variants {
        model: Quickshell.screens

        Wallpaper {}
    }

    Variants {
        model: Quickshell.screens

        Bar {}
    }

    IpcHandler {
        target: "bar"

        function toggle(monitor: string): void {
            BarVisibility.toggle(monitor);
        }

        function toggleFocused(): void {
            BarVisibility.toggleFocused();
        }
    }
}
