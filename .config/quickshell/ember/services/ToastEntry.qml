import QtQuick
import qs.services

QtObject {
    id: root

    readonly property int tickMs: 40

    property var notification: null
    property var entry: null
    property real lifetimeMs: 0
    property real remainingMs: 0
    property bool paused: false
    property bool closing: false
    property bool dismissed: false

    readonly property bool expires: root.lifetimeMs > 0
    readonly property real progress: root.expires
        ? Math.max(0, root.remainingMs / root.lifetimeMs)
        : 1

    readonly property Timer countdown: Timer {
        running: root.expires && !root.paused && !root.closing
        repeat: true
        interval: root.tickMs

        onTriggered: {
            root.remainingMs -= root.tickMs;
            if (root.remainingMs <= 0) Notifications.retire(root);
        }
    }

    readonly property Timer exit: Timer {
        running: root.closing
        interval: Theme.duration("normal")

        onTriggered: Notifications.finish(root)
    }
}
