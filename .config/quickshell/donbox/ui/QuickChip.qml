import QtQuick
import qs.services

Rectangle {
    id: root

    required property string label

    property string glyph: ""
    property bool selected: false

    readonly property color ink: root.selected
        ? Theme.onAccent
        : (Theme.palette.fg ?? "white")

    signal activated

    implicitWidth: layout.implicitWidth
        + (Theme.sizes.popupPadding ?? 0) * 2
    implicitHeight: Theme.sizes.hitTarget ?? 0
    radius: Theme.radii.normal ?? 0
    clip: true
    color: root.selected
        ? (Theme.palette.accent ?? "transparent")
        : (Theme.palette.surface ?? "transparent")
    border.width: Theme.sizes.borderWidth ?? 0
    border.color: area.containsMouse
        ? (Theme.palette.fg ?? "transparent")
        : (Theme.palette.border ?? "transparent")

    Behavior on color {
        ColorAnimation {
            duration: Theme.duration("quick")
            easing.type: Theme.easing("standard")
        }
    }

    Row {
        id: layout

        anchors.centerIn: parent
        spacing: Theme.spacing.tight ?? 0

        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.glyph !== ""
            text: root.glyph
            color: root.ink
            font.family: Theme.fonts.mono ?? ""
            font.pixelSize: Theme.sizes.iconNormal ?? 0
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.label
            color: root.ink
            font.family: Theme.fonts.ui ?? ""
            font.pixelSize: Theme.fontSizes.normal ?? 0
            font.weight: Theme.fontWeights.medium ?? 0
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
