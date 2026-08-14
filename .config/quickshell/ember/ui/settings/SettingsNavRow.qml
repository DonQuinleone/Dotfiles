import QtQuick
import qs.services

SettingsSurface {
    id: root

    required property var pane
    required property bool selected
    required property bool focused

    signal activated

    height: Metrics.rowHeight
    highlighted: root.selected
    hovered: area.containsMouse

    Row {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: Theme.spacing.normal ?? 0
        anchors.rightMargin: Theme.spacing.normal ?? 0
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.spacing.normal ?? 0

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.pane.glyph
            color: root.ink
            font.family: Theme.fonts.mono ?? ""
            font.pixelSize: Metrics.rowIcon
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.pane.title
            color: root.ink
            font.family: Theme.fonts.ui ?? ""
            font.pixelSize: Theme.fontSizes.large ?? 0
            font.weight: root.selected
                ? (Theme.fontWeights.bold ?? 0)
                : (Theme.fontWeights.medium ?? 0)
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
