import QtQuick
import qs.services

Column {
    id: root

    spacing: Theme.spacing.normal ?? 0

    Item {
        width: parent.width
        height: title.implicitHeight

        Text {
            id: title

            anchors.left: parent.left
            text: "Notifications"
            color: Theme.palette.fg ?? "white"
            font.family: Theme.fonts.ui ?? ""
            font.pixelSize: Theme.fontSizes.display ?? 0
            font.weight: Theme.fontWeights.bold ?? 0
        }

        Text {
            anchors.right: parent.right
            anchors.baseline: title.baseline
            text: `${NotificationStore.entries.length} kept`
            color: Theme.palette.fgDim ?? "white"
            font.family: Theme.fonts.ui ?? ""
            font.pixelSize: Theme.fontSizes.small ?? 0
        }
    }

    Row {
        spacing: Theme.spacing.tight ?? 0

        NotificationButton {
            text: NotificationStore.doNotDisturb
                ? "Do not disturb: on"
                : "Do not disturb: off"
            tint: NotificationStore.doNotDisturb
                ? (Theme.palette.warn ?? "white")
                : (Theme.palette.fg ?? "white")

            onActivated: NotificationStore.toggleDoNotDisturb()
        }

        NotificationButton {
            text: "Clear all"
            tint: Theme.palette.fg ?? "white"

            onActivated: NotificationStore.clear()
        }
    }
}
