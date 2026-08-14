import QtQuick
import Quickshell.Widgets
import qs.services

Column {
    id: root

    required property var modelData

    spacing: Theme.spacing.tight ?? 0

    Item {
        width: parent.width
        height: Theme.sizes.hitTarget ?? 0

        Row {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing: Theme.spacing.tight ?? 0

            IconImage {
                anchors.verticalCenter: parent.verticalCenter
                implicitSize: Theme.sizes.trayIcon ?? 0
                visible: root.modelData.icon !== ""
                source: root.modelData.icon
                asynchronous: true
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                visible: root.modelData.app !== ""
                text: root.modelData.app
                color: Theme.palette.fg ?? "white"
                font.family: Theme.fonts.ui ?? ""
                font.pixelSize: Theme.fontSizes.normal ?? 0
                font.weight: Theme.fontWeights.bold ?? 0
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: `${root.modelData.items.length}`
                color: Theme.palette.fgDim ?? "white"
                font.family: Theme.fonts.ui ?? ""
                font.pixelSize: Theme.fontSizes.small ?? 0
            }
        }

        NotificationButton {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: "Clear"
            tint: Theme.palette.fgDim ?? "white"

            onActivated: NotificationStore.clearApp(root.modelData.app)
        }
    }

    Repeater {
        model: root.modelData.items

        NotificationEntry {
            width: root.width
        }
    }
}
