import QtQuick
import qs.services

Rectangle {
    id: root

    default property alias content: body.data

    required property string title

    readonly property int padding: Theme.sizes.popupPadding ?? 0

    implicitHeight: layout.implicitHeight + root.padding * 2
    color: Theme.palette.bgAlt ?? "transparent"
    radius: Theme.radii.large ?? 0
    border.width: Theme.sizes.borderWidth ?? 0
    border.color: Theme.palette.border ?? "transparent"

    Column {
        id: layout

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: root.padding
        spacing: Theme.spacing.loose ?? 0

        Text {
            width: parent.width
            text: root.title
            color: Theme.palette.accent ?? "white"
            font.family: Theme.fonts.ui ?? ""
            font.pixelSize: Theme.fontSizes.display ?? 0
            font.weight: Theme.fontWeights.bold ?? 0
        }

        Column {
            id: body

            width: parent.width
            spacing: Theme.spacing.section ?? 0
        }
    }
}
