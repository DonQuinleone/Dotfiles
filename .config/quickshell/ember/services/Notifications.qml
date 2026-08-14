pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Singleton {
    id: root

    readonly property int tickMs: 40
    readonly property int msPerSecond: 1000
    readonly property int maxToasts: 5

    readonly property var lifetimesMs: ({
        [NotificationUrgency.Low]: 4000,
        [NotificationUrgency.Normal]: 7000,
        [NotificationUrgency.Critical]: 0
    })

    readonly property var tintRoles: ({
        [NotificationUrgency.Low]: "fgDim",
        [NotificationUrgency.Normal]: "accent",
        [NotificationUrgency.Critical]: "bad"
    })

    readonly property var urgencyLabels: ({
        [NotificationUrgency.Low]: "",
        [NotificationUrgency.Normal]: "",
        [NotificationUrgency.Critical]: "Critical"
    })

    property var toasts: []
    property bool centreOpen: false

    function tint(urgency: int): color {
        return Theme.palette[root.tintRoles[urgency] ?? "accent"]
            ?? "transparent";
    }

    function label(urgency: int): string {
        return root.urgencyLabels[urgency] ?? "";
    }

    function toggleCentre(): void {
        root.centreOpen = !root.centreOpen;
        if (root.centreOpen) NotificationStore.markSeen();
    }

    function iconFor(notification: var): string {
        const named = notification.appIcon;
        if (!named) return root.desktopIcon(notification);
        if (named.startsWith("/")) return named;
        const themed = Quickshell.iconPath(named, true);
        return themed !== "" ? themed : root.desktopIcon(notification);
    }

    function desktopIcon(notification: var): string {
        const key = notification.desktopEntry || notification.appName;
        const entry = key ? DesktopEntries.heuristicLookup(key) : null;
        if (!entry?.icon) return "";
        return Quickshell.iconPath(entry.icon, true);
    }

    function describe(notification: var): var {
        return {
            app: notification.appName || "Unknown",
            icon: root.iconFor(notification),
            summary: notification.summary,
            body: notification.body,
            image: notification.image,
            urgency: notification.urgency,
            time: Date.now()
        };
    }

    function lifetimeFor(notification: var): real {
        if (notification.urgency === NotificationUrgency.Critical)
            return 0;
        const requested = notification.expireTimeout;
        if (requested >= 0) return requested * root.msPerSecond;
        return root.lifetimesMs[notification.urgency] ?? 0;
    }

    function suppressed(notification: var): bool {
        return NotificationStore.doNotDisturb
            && notification.urgency !== NotificationUrgency.Critical;
    }

    function accept(notification: var): void {
        notification.tracked = true;
        NotificationStore.record(root.describe(notification));
        if (root.suppressed(notification)) {
            notification.dismiss();
            return;
        }
        NotificationRules.announce(notification);
        root.show(notification);
    }

    function show(notification: var): void {
        const lifetime = root.lifetimeFor(notification);
        const entry = toastEntry.createObject(root, {
            notification: notification,
            lifetimeMs: lifetime,
            remainingMs: lifetime
        });
        notification.closed.connect(() => root.forget(entry));
        root.toasts = [entry].concat(root.toasts);
        root.overflow();
    }

    function overflow(): void {
        root.toasts.slice(root.maxToasts)
            .forEach(entry => root.expire(entry));
    }

    function beginClose(entry: var, expired: bool): void {
        if (entry.closing) return;
        entry.expired = expired;
        entry.closeMs = Theme.duration("normal");
        entry.closing = true;
    }

    function dismiss(entry: var): void {
        root.beginClose(entry, false);
    }

    function expire(entry: var): void {
        root.beginClose(entry, true);
    }

    function dismissAll(): void {
        root.toasts.forEach(entry => root.dismiss(entry));
    }

    function defaultAction(notification: var): var {
        return notification.actions
            .find(action => action.identifier === "default") ?? null;
    }

    function activate(entry: var): void {
        const action = root.defaultAction(entry.notification);
        if (action) action.invoke();
        root.dismiss(entry);
    }

    function invoke(entry: var, action: var): void {
        action.invoke();
        root.dismiss(entry);
    }

    function countdown(entry: var): void {
        if (entry.paused || !entry.expires) return;
        entry.remainingMs -= root.tickMs;
        if (entry.remainingMs > 0) return;
        root.expire(entry);
    }

    function advanceClose(entry: var): void {
        entry.closeMs -= root.tickMs;
        if (entry.closeMs > 0) return;
        root.finishClose(entry);
    }

    function finishClose(entry: var): void {
        const notification = entry.notification;
        if (!notification) return;
        if (entry.expired) {
            notification.expire();
            return;
        }
        notification.dismiss();
    }

    function forget(entry: var): void {
        if (root.toasts.indexOf(entry) < 0) return;
        root.toasts = root.toasts.filter(item => item !== entry);
        entry.destroy();
    }

    function tick(): void {
        const closing = root.toasts.filter(entry => entry.closing);
        root.toasts
            .filter(entry => !entry.closing)
            .forEach(entry => root.countdown(entry));
        closing.forEach(entry => root.advanceClose(entry));
    }

    Component {
        id: toastEntry

        ToastEntry {}
    }

    NotificationServer {
        actionsSupported: true
        actionIconsSupported: true
        bodySupported: true
        bodyMarkupSupported: true
        bodyImagesSupported: true
        imageSupported: true
        persistenceSupported: true

        onNotification: notification => root.accept(notification)
    }

    Timer {
        running: root.toasts.length > 0
        repeat: true
        interval: root.tickMs

        onTriggered: root.tick()
    }
}
