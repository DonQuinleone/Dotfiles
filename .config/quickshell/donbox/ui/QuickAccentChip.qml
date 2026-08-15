import QtQuick
import qs.services

Rectangle {
    id: root

    required property string name
    required property color swatch
    required property bool selected

    readonly property string tick: "󰄬"
    readonly property int selectedBorderFactor: 2
    readonly property bool outlined: root.selected || area.containsMouse

    signal activated

    implicitWidth: layout.implicitWidth
        + (Theme.sizes.popupPadding ?? 0) * 2
    implicitHeight: Theme.sizes.hitTarget ?? 0
    radius: Theme.radii.normal ?? 0
    color: root.swatch
    border.width: (Theme.sizes.borderWidth ?? 0)
        * (root.selected ? root.selectedBorderFactor : 1)
    border.color: root.outlined
        ? (Theme.palette.fg ?? "transparent")
        : (Theme.palette.border ?? "transparent")

    Row {
        id: layout

        anchors.centerIn: parent
        spacing: Theme.spacing.tight ?? 0

        Text {
            anchors.verticalCenter: parent.verticalCenter
            opacity: root.selected ? (Theme.opacities.full ?? 1) : 0
            text: root.tick
            color: Theme.readableOn(root.swatch)
            font.family: Theme.fonts.mono ?? ""
            font.pixelSize: Theme.fontSizes.normal ?? 0
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.name
            color: Theme.readableOn(root.swatch)
            font.family: Theme.fonts.ui ?? ""
            font.pixelSize: Theme.fontSizes.normal ?? 0
            font.weight: Theme.fontWeights.bold ?? 0
        }
    }

    MouseArea {
        id: area

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: root.activated()
    }
}
