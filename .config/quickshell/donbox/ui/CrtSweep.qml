import QtQuick
import qs.services

Rectangle {
    id: root

    readonly property int sweepMs: 900

    implicitHeight: Theme.spacing.normal ?? 0
    color: Theme.palette.surface ?? "grey"
    clip: true

    Rectangle {
        id: block

        width: root.width * LockMetrics.sweepShare
        height: root.height
        color: Theme.palette.accent ?? "white"
    }

    SequentialAnimation {
        running: root.visible
        loops: Animation.Infinite

        NumberAnimation {
            target: block
            property: "x"
            from: 0
            to: root.width - block.width
            duration: root.sweepMs
            easing.type: Theme.easing("standard")
        }

        NumberAnimation {
            target: block
            property: "x"
            from: root.width - block.width
            to: 0
            duration: root.sweepMs
            easing.type: Theme.easing("standard")
        }
    }
}
