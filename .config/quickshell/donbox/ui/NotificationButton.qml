import QtQuick
import qs.services

Rectangle {
    id: root

    property alias text: label.text
    property color tint: Theme.palette.fg ?? "white"

    signal activated

    implicitWidth: Math.max(Theme.sizes.hitTarget ?? 0,
        label.implicitWidth + (Theme.sizes.popupPadding ?? 0) * 2)
    implicitHeight: Theme.sizes.hitTarget ?? 0
    radius: Theme.radii.normal ?? 0
    color: area.containsMouse
        ? (Theme.palette.surface ?? "transparent")
        : Qt.alpha(Theme.palette.surface ?? "black", 0)
    border.width: Theme.sizes.borderWidth ?? 0
    border.color: area.containsMouse
        ? root.tint
        : (Theme.palette.border ?? "transparent")

    Behavior on color {
        ColorAnimation {
            duration: Theme.duration("quick")
            easing.type: Theme.easing("standard")
        }
    }

    Behavior on border.color {
        ColorAnimation {
            duration: Theme.duration("quick")
            easing.type: Theme.easing("standard")
        }
    }

    Text {
        id: label

        anchors.centerIn: parent
        color: root.tint
        font.family: Theme.fonts.ui ?? ""
        font.pixelSize: Theme.fontSizes.normal ?? 0
        font.weight: Theme.fontWeights.medium ?? 0
    }

    MouseArea {
        id: area

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: root.activated()
    }
}
