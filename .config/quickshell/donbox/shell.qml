import Quickshell
import Quickshell.Io
import qs.services
import qs.ui
import qs.ui.settings

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

    Variants {
        model: Quickshell.screens

        ScreensaverWindow {}
    }

    LockScreen {}

    SettingsWindow {}

    IpcHandler {
        target: "settings"

        function toggle(): void {
            Settings.toggle();
        }

        function open(): void {
            Settings.show();
        }

        function pane(name: string): void {
            Settings.reveal(name);
        }

        function close(): void {
            Settings.hide();
        }
    }

    IpcHandler {
        target: "lock"

        function lock(): void {
            Lock.lock();
        }

        function unlock(): void {
            Lock.unlock();
        }
    }

    IpcHandler {
        target: "screensaver"

        function start(): void {
            Screensaver.start();
        }

        function stop(): void {
            Screensaver.stop();
        }

        function set(name: string): string {
            return Screensaver.select(name);
        }

        function get(): string {
            return Screensaver.choice;
        }

        function list(): string {
            return Screensaver.names();
        }
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

        function cancel(): void {
            Picker.cancel();
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
