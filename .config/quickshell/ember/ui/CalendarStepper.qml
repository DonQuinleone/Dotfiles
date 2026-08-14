import QtQuick
import qs.services

Rectangle {
    id: root

    required property string glyph

    signal stepped

    width: Theme.sizes.hitTarget ?? 0
    height: Theme.sizes.hitTarget ?? 0
    radius: Theme.radii.normal ?? 0
    color: area.containsMouse
        ? (Theme.palette.surface ?? "transparent")
        : Qt.alpha(Theme.palette.surface ?? "black", 0)

    Text {
        anchors.centerIn: parent
        text: root.glyph
        color: Theme.palette.fg ?? "white"
        font.family: Theme.fonts.ui ?? ""
        font.pixelSize: Theme.fontSizes.display ?? 0
        font.weight: Theme.fontWeights.bold ?? 0
    }

    MouseArea {
        id: area

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: root.stepped()
    }
}
