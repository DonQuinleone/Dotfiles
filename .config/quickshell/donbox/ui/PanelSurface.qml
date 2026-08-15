import QtQuick
import Quickshell
import qs.services

PopupWindow {
    id: root

    default property alias body: content.data

    property real widthFactor: 1.5
    property real screenShare: 0.7

    readonly property int panelWidth:
        (Theme.sizes.menuWidth ?? 0) * root.widthFactor
    readonly property int padding: Theme.sizes.popupPadding ?? 0
    readonly property int gap: Theme.spacing.tight ?? 0

    readonly property int tallest: root.screen
        ? root.screen.height * root.screenShare
        : content.implicitHeight

    color: Qt.alpha(Theme.palette.bg ?? "black", 0)
    implicitWidth: root.panelWidth
    implicitHeight: frame.implicitHeight + root.gap
    visible: false

    PopoverGrab {
        surface: root
        shown: root.visible

        onDismissed: root.visible = false
    }

    Rectangle {
        id: frame

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        implicitHeight: scroller.height + root.padding * 2
        color: Theme.palette.bgAlt ?? "black"
        radius: Theme.radii.large ?? 0
        border.width: Theme.sizes.borderWidth ?? 0
        border.color: Theme.palette.border ?? "transparent"

        Flickable {
            id: scroller

            x: root.padding
            y: root.padding
            width: parent.width - root.padding * 2
                - Metrics.trackWidth
            height: Math.min(content.implicitHeight, root.tallest)
            contentWidth: this.width
            contentHeight: content.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            Column {
                id: content

                width: scroller.width
                spacing: Theme.spacing.loose ?? 0
            }
        }

        ChooserScrollBar {
            anchors.top: scroller.top
            anchors.bottom: scroller.bottom
            anchors.right: parent.right
            anchors.rightMargin: root.padding
            view: scroller
        }
    }
}
