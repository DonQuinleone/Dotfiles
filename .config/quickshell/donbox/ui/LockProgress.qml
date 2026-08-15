import QtQuick
import qs.services

Rectangle {
    id: root

    readonly property real blockShare: 0.3
    readonly property int sweepMs: 900

    implicitWidth: Metrics.lockFieldWidth
    implicitHeight: Theme.spacing.normal ?? 0
    radius: height / 2
    color: Theme.palette.surface ?? "grey"
    clip: true

    Rectangle {
        id: block

        width: root.width * root.blockShare
        height: root.height
        radius: root.radius
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
