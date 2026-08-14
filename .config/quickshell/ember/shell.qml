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

    Variants {
        model: Quickshell.screens

        LauncherWindow {}
    }

    Variants {
        model: Quickshell.screens

        PickerWindow {}
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

    IpcHandler {
        target: "launcher"

        function toggle(): void {
            Launcher.toggle();
        }

        function open(): void {
            Launcher.show();
        }

        function close(): void {
            Launcher.hide();
        }
    }

    IpcHandler {
        target: "pick"

        function open(request: string): string {
            return Picker.present(request);
        }
    }
}
