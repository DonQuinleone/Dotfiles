pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

Singleton {
    id: root

    readonly property string configHome:
        Quickshell.env("XDG_CONFIG_HOME")
        ?? `${Quickshell.env("HOME")}/.config`

    readonly property string path:
        `${root.configHome}/quickshell/notifications.json`

    readonly property string soundScript:
        `${root.configHome}/hypr/scripts/notify-sound`

    readonly property string speakScript:
        `${root.configHome}/hypr/scripts/speak`

    readonly property var urgencyNames: ({
        [NotificationUrgency.Low]: "low",
        [NotificationUrgency.Normal]: "normal",
        [NotificationUrgency.Critical]: "critical"
    })

    readonly property var placeholders: ({
        "{summary}": "summary",
        "{body}": "body",
        "{app}": "appName"
    })

    property var data: ({})

    readonly property var defaults: root.data.defaults ?? ({})
    readonly property var applications: root.data.applications ?? ({})

    function plain(value: var): string {
        if (value === undefined || value === null) return "";
        return `${value}`;
    }

    function ruleFor(appName: var, desktopEntry: var): var {
        const apps = root.applications;
        const exact = apps[desktopEntry] ?? apps[appName];
        if (exact) return exact;
        const wanted = root.plain(appName).toLowerCase();
        const key = Object.keys(apps)
            .find(name => name.toLowerCase() === wanted);
        return key ? apps[key] : ({});
    }

    function fallbackFor(urgency: int): var {
        return root.defaults[root.urgencyNames[urgency]] ?? ({});
    }

    function setting(rule: var, fallback: var, name: string): var {
        return rule[name] !== undefined ? rule[name] : fallback[name];
    }

    function valueOf(notification: var, token: string): string {
        return root.plain(notification[root.placeholders[token]]);
    }

    function fill(template: var, notification: var): string {
        return Object.keys(root.placeholders).reduce(
            (text, token) => text.split(token)
                .join(root.valueOf(notification, token)),
            root.plain(template));
    }

    function unresolved(template: var, notification: var): bool {
        const text = root.plain(template);
        return Object.keys(root.placeholders).some(
            token => text.indexOf(token) >= 0
                && !root.valueOf(notification, token));
    }

    function playSound(name: var): void {
        const sound = root.plain(name);
        if (!sound) return;
        Quickshell.execDetached([root.soundScript, sound]);
    }

    function speak(template: var, notification: var): void {
        if (root.unresolved(template, notification)) return;
        const text = root.fill(template, notification).trim();
        if (!text) return;
        Quickshell.execDetached([root.speakScript, text]);
    }

    function announce(notification: var): void {
        const rule = root.ruleFor(
            notification.appName, notification.desktopEntry);
        const fallback = root.fallbackFor(notification.urgency);
        root.playSound(root.setting(rule, fallback, "sound"));
        root.speak(root.setting(rule, fallback, "speak"), notification);
    }

    function reparse(): void {
        try {
            root.data = JSON.parse(file.text());
        } catch (error) {
            console.error(
                `ember: ${root.path} is not valid JSON:`, error);
        }
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
            `ember: cannot read ${root.path}:`,
            FileViewError.toString(error))
    }
}
