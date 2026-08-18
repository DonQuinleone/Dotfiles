import QtQuick
import qs.services

Rectangle {
    id: root

    required property string zone

    readonly property int gap: Theme.spacing.normal ?? 0

    implicitHeight: Math.max(Theme.sizes.hitTarget ?? 0,
        naming.implicitHeight + (Theme.spacing.tight ?? 0) * 2)
    radius: Theme.radii.normal ?? 0
    color: Theme.palette.surface ?? "transparent"

    Column {
        id: naming

        anchors.left: parent.left
        anchors.leftMargin: root.gap
        anchors.right: reading.left
        anchors.rightMargin: root.gap
        anchors.verticalCenter: parent.verticalCenter

        Text {
            width: parent.width
            elide: Text.ElideRight
            text: WorldClocks.labelOf(root.zone)
            color: Theme.palette.fg ?? "white"
            font.family: Theme.fonts.ui ?? ""
            font.pixelSize: Theme.fontSizes.normal ?? 0
            font.weight: Theme.fontWeights.medium ?? 0
        }

        Text {
            width: parent.width
            elide: Text.ElideRight
            text: WorldClocks.regionOf(root.zone)
            color: Theme.palette.fgDim ?? "white"
            font.family: Theme.fonts.ui ?? ""
            font.pixelSize: Theme.fontSizes.small ?? 0
        }
    }

    Text {
        id: reading

        anchors.right: drop.left
        anchors.rightMargin: root.gap
        anchors.verticalCenter: parent.verticalCenter
        text: WorldClocks.timeOf(root.zone)
        color: Theme.palette.fg ?? "white"
        font.family: Theme.fonts.mono ?? ""
        font.pixelSize: Theme.fontSizes.large ?? 0
        font.weight: Theme.fontWeights.bold ?? 0
        font.features: ({ "tnum": 1 })
    }

    QuickChip {
        id: drop

        anchors.right: parent.right
        anchors.rightMargin: root.gap
        anchors.verticalCenter: parent.verticalCenter
        label: "Remove"

        onActivated: WorldClocks.remove(root.zone)
    }
}
