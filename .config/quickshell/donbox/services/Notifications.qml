pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Singleton {
    id: root

    readonly property int maxToasts: 5
    readonly property int motionMs: Theme.duration("flash")
    readonly property int grabSettleMs: 250
    readonly property string unnamedApp: "Notification"
    readonly property string defaultAction: "default"
    readonly property string senderPidHint: "sender-pid"

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

    readonly property alias toasts: toastModel

    property bool centreOpen: false
    property real closedCentreAtMs: 0

    function tint(urgency: int): color {
        return Theme.palette[root.tintRoles[urgency] ?? "accent"]
            ?? "transparent";
    }

    function label(urgency: int): string {
        return root.urgencyLabels[urgency] ?? "";
    }

    function toggleCentre(): void {
        if (Date.now() - root.closedCentreAtMs < root.grabSettleMs)
            return;
        root.centreOpen = !root.centreOpen;
    }

    function closeCentre(): void {
        root.centreOpen = false;
        root.closedCentreAtMs = Date.now();
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

    function senderFor(notification: var): string {
        const named = notification.appName;
        if (named && !NotificationSender.anonymous(named)) return named;
        const hints = notification.hints ?? ({});
        const resolved =
            NotificationSender.nameFor(hints[root.senderPidHint]);
        return resolved || named || root.unnamedApp;
    }

    function headline(notification: var): var {
        const summary = notification.summary.trim();
        const body = notification.body;
        if (summary) return { summary: summary, body: body };
        const lines = body.split("\n");
        return {
            summary: (lines[0] ?? "").trim(),
            body: lines.slice(1).join("\n").trim()
        };
    }

    function actionsOf(notification: var): var {
        return notification.actions
            .filter(action => action.identifier !== root.defaultAction
                && action.text !== "")
            .map(action => ({
                identifier: action.identifier,
                text: action.text
            }));
    }

    function describe(notification: var): var {
        const spoken = root.headline(notification);
        return {
            app: root.senderFor(notification),
            icon: root.iconFor(notification),
            summary: spoken.summary,
            body: spoken.body,
            image: notification.image,
            urgency: notification.urgency,
            time: Date.now(),
            transient: notification.transient,
            seen: false,
            actions: root.actionsOf(notification),
            live: notification
        };
    }

    function lifetimeFor(notification: var): real {
        if (notification.urgency === NotificationUrgency.Critical)
            return 0;
        const requested = notification.expireTimeout;
        if (requested >= 0) return requested;
        return root.lifetimesMs[notification.urgency] ?? 0;
    }

    function suppressed(notification: var): bool {
        return NotificationStore.doNotDisturb
            && notification.urgency !== NotificationUrgency.Critical;
    }

    function closed(entry: var, reason: int): void {
        entry.live = null;
        if (reason === NotificationCloseReason.Expired) return;
        NotificationStore.discard(entry);
    }

    function keep(notification: var, entry: var): void {
        NotificationStore.record(entry);
        notification.closed.connect(
            reason => root.closed(entry, reason));
    }

    function silence(entry: var): void {
        if (entry.transient) return;
        NotificationStore.release(entry);
    }

    function accept(notification: var): void {
        notification.tracked = true;
        const entry = root.describe(notification);
        if (!entry.transient) root.keep(notification, entry);
        if (root.suppressed(notification)) {
            root.silence(entry);
            return;
        }
        NotificationRules.announce(notification);
        root.show(notification, entry);
    }

    function show(notification: var, entry: var): void {
        const lifetime = root.lifetimeFor(notification);
        const toast = toastEntry.createObject(root, {
            notification: notification,
            entry: entry,
            lifetimeMs: lifetime,
            remainingMs: lifetime
        });
        notification.closed.connect(() => root.drop(toast));
        toastModel.insert(0, { toast: toast });
        root.overflow();
    }

    function indexOf(toast: var): int {
        for (let index = 0; index < toastModel.count; index++) {
            if (toastModel.get(index).toast === toast) return index;
        }
        return -1;
    }

    function overflow(): void {
        for (let index = toastModel.count - 1;
            index >= root.maxToasts; index--) {
            root.retire(toastModel.get(index).toast);
        }
    }

    function beginClose(toast: var, dismissed: bool): void {
        if (toast.closing) return;
        toast.dismissed = dismissed;
        toast.closing = true;
    }

    function retire(toast: var): void {
        root.beginClose(toast, false);
    }

    function dismiss(toast: var): void {
        root.beginClose(toast, true);
    }

    function dismissAll(): void {
        for (let index = 0; index < toastModel.count; index++) {
            root.dismiss(toastModel.get(index).toast);
        }
    }

    function drop(toast: var): void {
        const index = root.indexOf(toast);
        if (index < 0) return;
        toastModel.remove(index);
        toast.destroy();
    }

    function finish(toast: var): void {
        if (toast.dismissed) NotificationStore.forget(toast.entry);
        else NotificationStore.release(toast.entry);
        root.drop(toast);
    }

    function fire(entry: var, identifier: string): void {
        const live = entry.live;
        if (!live) return;
        const action = live.actions
            .find(item => item.identifier === identifier);
        if (action) action.invoke();
    }

    function invoke(toast: var, identifier: string): void {
        root.fire(toast.entry, identifier);
        root.dismiss(toast);
    }

    function trigger(entry: var, identifier: string): void {
        root.fire(entry, identifier);
        NotificationStore.forget(entry);
    }

    function activate(toast: var): void {
        root.invoke(toast, root.defaultAction);
    }

    onCentreOpenChanged:
        if (root.centreOpen) NotificationStore.markSeen()

    ListModel {
        id: toastModel

        dynamicRoles: true
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
        extraHints: [root.senderPidHint]

        onNotification: notification => root.accept(notification)
    }
}
