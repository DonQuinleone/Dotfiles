import QtQuick
import Quickshell.Widgets
import qs.services

Item {
    id: root

    required property var toast
    required property color tint
    required property string label

    readonly property var entry: root.toast.entry

    implicitHeight: Theme.sizes.hitTarget ?? 0

    Row {
        anchors.left: parent.left
        anchors.right: close.left
        anchors.rightMargin: Theme.spacing.normal ?? 0
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.spacing.tight ?? 0

        IconImage {
            anchors.verticalCenter: parent.verticalCenter
            implicitSize: Theme.sizes.trayIcon ?? 0
            visible: root.entry.icon !== ""
            source: root.entry.icon
            asynchronous: true
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.entry.app !== ""
            text: root.entry.app
            color: Theme.palette.fgDim ?? "white"
            font.family: Theme.fonts.ui ?? ""
            font.pixelSize: Theme.fontSizes.small ?? 0
            font.weight: Theme.fontWeights.medium ?? 0
            font.letterSpacing: Theme.spacing.hair ?? 0
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.label !== ""
            text: root.label
            color: root.tint
            font.family: Theme.fonts.ui ?? ""
            font.pixelSize: Theme.fontSizes.small ?? 0
            font.weight: Theme.fontWeights.bold ?? 0
            font.letterSpacing: Theme.spacing.hair ?? 0
        }
    }

    NotificationButton {
        id: close

        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        text: "✕"
        tint: Theme.palette.fgDim ?? "white"

        onActivated: Notifications.dismiss(root.toast)
    }
}
