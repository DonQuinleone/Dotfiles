import QtQuick
import qs.services

Rectangle {
    id: root

    required property Flickable view

    readonly property real span: root.view.visibleArea.heightRatio
    readonly property int minimumHandle: Theme.sizes.hitTarget ?? 0

    width: Metrics.scrollBarWidth
    radius: Theme.radii.round ?? 0
    visible: root.span < 1
    color: Qt.alpha(Theme.palette.border ?? "black",
        Theme.opacities.muted ?? 0)

    Rectangle {
        width: parent.width
        height: Math.max(root.height * root.span, root.minimumHandle)
        y: Math.min(root.height * root.view.visibleArea.yPosition,
            root.height - this.height)
        radius: parent.radius
        color: Theme.palette.accent ?? "transparent"
    }
}
