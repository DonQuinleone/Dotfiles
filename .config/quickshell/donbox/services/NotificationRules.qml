pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import "logic"

Singleton {
    id: root

    readonly property string configHome:
        Quickshell.env("XDG_CONFIG_HOME")
        ?? `${Quickshell.env("HOME")}/.config`

    readonly property string path:
        `${root.configHome}/quickshell/notifications.json`

    readonly property var soundCommand:
        [Preferences.donbox, "notify", "sound"]

    readonly property var urgencyNames: ({
        [NotificationUrgency.Low]: "low",
        [NotificationUrgency.Normal]: "normal",
        [NotificationUrgency.Critical]: "critical"
    })

    property var data: ({})

    readonly property var defaults: root.data.defaults ?? ({})
    readonly property var applications: root.data.applications ?? ({})

    function playSound(name: var): void {
        const sound = match.plain(name);
        if (!sound) return;
        Quickshell.execDetached(root.soundCommand.concat([sound]));
    }

    function announce(notification: var): void {
        const rule = match.ruleFor(root.applications,
            notification.appName, notification.desktopEntry);
        const fallback = match.fallbackFor(root.defaults,
            root.urgencyNames[notification.urgency]);
        root.playSound(match.setting(rule, fallback, "sound"));
    }

    function reparse(): void {
        try {
            root.data = JSON.parse(file.text());
        } catch (error) {
            console.error(
                `donbox: ${root.path} is not valid JSON:`, error);
        }
    }

    NotificationMatch {
        id: match
    }

    Component.onCompleted: root.reparse()

    FileView {
        id: file

        path: root.path
        watchChanges: true
        blockLoading: true

        onFileChanged: this.reload()
        onLoaded: root.reparse()
        onLoadFailed: error => console.error(
            `donbox: cannot read ${root.path}:`,
            FileViewError.toString(error))
    }
}
