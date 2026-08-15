import QtQuick
import qs.services

Rectangle {
    id: root

    required property var alarm

    readonly property int gap: Theme.spacing.normal ?? 0

    implicitHeight: Theme.sizes.hitTarget ?? 0
    radius: Theme.radii.normal ?? 0
    color: root.alarm.enabled
        ? (Theme.palette.surface ?? "transparent")
        : (Theme.palette.bgAlt ?? "transparent")

    Text {
        id: reading

        anchors.left: parent.left
        anchors.leftMargin: root.gap
        anchors.verticalCenter: parent.verticalCenter
        text: Alarms.clockOf(root.alarm.hour, root.alarm.minute)
        color: root.alarm.enabled
            ? (Theme.palette.fg ?? "white")
            : (Theme.palette.fgDim ?? "white")
        font.family: Theme.fonts.mono ?? ""
        font.pixelSize: Theme.fontSizes.large ?? 0
        font.weight: Theme.fontWeights.bold ?? 0
        font.features: ({ "tnum": 1 })
    }

    Row {
        anchors.right: parent.right
        anchors.rightMargin: root.gap
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.spacing.tight ?? 0

        QuickChip {
            label: root.alarm.enabled ? "On" : "Off"
            selected: root.alarm.enabled

            onActivated: Alarms.toggle(root.alarm)
        }

        QuickChip {
            label: "Remove"

            onActivated: Alarms.remove(root.alarm)
        }
    }
}
