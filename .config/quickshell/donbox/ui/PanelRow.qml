import QtQuick
import qs.services

Rectangle {
    id: root

    required property string glyph
    required property string title
    required property string status
    required property string actionLabel
    required property bool actionOffered
    required property bool current

    signal chosen

    readonly property int gap: Theme.spacing.normal ?? 0

    implicitHeight: Theme.sizes.hitTarget ?? 0
    radius: Theme.radii.normal ?? 0
    color: root.current
        ? (Theme.palette.surface ?? "transparent")
        : (Theme.palette.bgAlt ?? "transparent")

    Text {
        id: mark

        anchors.left: parent.left
        anchors.leftMargin: root.gap
        anchors.verticalCenter: parent.verticalCenter
        text: root.glyph
        color: root.current
            ? (Theme.palette.accent ?? "white")
            : (Theme.palette.fgDim ?? "white")
        font.family: Theme.fonts.mono ?? ""
        font.pixelSize: Theme.sizes.iconNormal ?? 0
    }

    Column {
        anchors.left: mark.right
        anchors.leftMargin: root.gap
        anchors.right: action.left
        anchors.rightMargin: root.gap
        anchors.verticalCenter: parent.verticalCenter

        Text {
            width: parent.width
            elide: Text.ElideRight
            text: root.title
            color: Theme.palette.fg ?? "white"
            font.family: Theme.fonts.ui ?? ""
            font.pixelSize: Theme.fontSizes.normal ?? 0
            font.weight: Theme.fontWeights.medium ?? 0
        }

        Text {
            width: parent.width
            elide: Text.ElideRight
            text: root.status
            color: Theme.palette.fgDim ?? "white"
            font.family: Theme.fonts.ui ?? ""
            font.pixelSize: Theme.fontSizes.small ?? 0
        }
    }

    QuickChip {
        id: action

        anchors.right: parent.right
        anchors.rightMargin: root.gap
        anchors.verticalCenter: parent.verticalCenter
        visible: root.actionOffered
        label: root.actionLabel

        onActivated: root.chosen()
    }
}
