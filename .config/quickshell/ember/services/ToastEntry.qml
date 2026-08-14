import QtQuick

QtObject {
    id: root

    property var notification: null
    property real lifetimeMs: 0
    property real remainingMs: 0
    property real closeMs: 0
    property bool paused: false
    property bool closing: false
    property bool expired: false

    readonly property bool expires: root.lifetimeMs > 0
    readonly property real progress: root.expires
        ? Math.max(0, root.remainingMs / root.lifetimeMs)
        : 1
}
