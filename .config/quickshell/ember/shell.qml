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

    Variants {
        model: Quickshell.screens

        ToastLayer {}
    }

    Variants {
        model: Quickshell.screens

        OsdWindow {}
    }

    Variants {
        model: Quickshell.screens

        NotificationCentre {}
    }

    Variants {
        model: Quickshell.screens

        QuickSettingsPanel {}
    }

    Variants {
        id: flashes

        model: Quickshell.screens

        FlashOverlay {}
    }

    IpcHandler {
        target: "screenshot"

        function flash(): void {
            for (const window of flashes.instances) window.flash();
        }
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

    IpcHandler {
        target: "quickSettings"

        function toggle(): void {
            QuickSettings.toggle();
        }

        function open(): void {
            QuickSettings.show();
        }

        function close(): void {
            QuickSettings.hide();
        }
    }

    IpcHandler {
        target: "notifications"

        function toggleCentre(): void {
            Notifications.toggleCentre();
        }

        function toggleDnd(): void {
            NotificationStore.toggleDoNotDisturb();
        }

        function dismissAll(): void {
            Notifications.dismissAll();
        }
    }
}
