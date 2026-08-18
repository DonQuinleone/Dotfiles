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
        id: flashes

        model: Quickshell.screens

        FlashOverlay {}
    }

    Variants {
        model: Quickshell.screens

        ScreensaverWindow {}
    }

    LockScreen {}

    BatteryAlerts {}

    BluetoothAlerts {}

    IpcHandler {
        target: "panels"

        function toggle(name: string): void {
            Panels.toggle(name);
        }

        function close(): void {
            Panels.close();
        }

        function open(): string {
            return Panels.open;
        }

        function grabbed(): bool {
            return Panels.grabActive;
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
        target: "notifications"

        function toggleCentre(): void {
            Notifications.toggleCentre();
        }

        function toggleDnd(): void {
            NotificationStore.toggleDoNotDisturb();
        }

        function dismissAll(): void {
            Notifications.dismissAll();
            NotificationStore.clear();
        }
    }

    IpcHandler {
        target: "osd"

        function quietBrightness(): void {
            Osd.quietBrightness();
        }
    }
}
