import QtQuick
import qs.services

Rectangle {
    id: root

    required property string glyph
    required property string title
    required property string detail
    required property bool active

    readonly property color ink: root.active
        ? Theme.onAccent
        : (Theme.palette.fg ?? "white")

    signal activated

    implicitHeight: (Theme.sizes.hitTarget ?? 0)
        + (Theme.spacing.loose ?? 0)
    radius: Theme.radii.normal ?? 0
    color: root.active
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
        anchors.fill: parent
        anchors.leftMargin: Theme.spacing.normal ?? 0
        anchors.rightMargin: Theme.spacing.normal ?? 0
        spacing: Theme.spacing.normal ?? 0

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.glyph
            color: root.ink
            font.family: Theme.fonts.mono ?? ""
            font.pixelSize: Theme.sizes.iconNormal ?? 0
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - this.x - (Theme.spacing.normal ?? 0)

            Text {
                width: parent.width
                elide: Text.ElideRight
                text: root.title
                color: root.ink
                font.family: Theme.fonts.ui ?? ""
                font.pixelSize: Theme.fontSizes.normal ?? 0
                font.weight: Theme.fontWeights.bold ?? 0
            }

            Text {
                width: parent.width
                elide: Text.ElideRight
                text: root.detail
                color: root.ink
                opacity: Theme.opacities.muted ?? 1
                font.family: Theme.fonts.ui ?? ""
                font.pixelSize: Theme.fontSizes.small ?? 0
            }
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
