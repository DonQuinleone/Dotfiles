import QtQuick
import qs.services

Rectangle {
    id: root

    required property var item
    required property bool selected

    signal activated
    signal entered

    readonly property color labelColour: root.selected
        ? Theme.onAccent
        : (Theme.palette.fg ?? "white")

    readonly property color subtitleColour: root.selected
        ? Theme.onAccent
        : (Theme.palette.fgDim ?? "white")

    implicitHeight: Metrics.rowHeight
    radius: Theme.radii.normal ?? 0
    color: root.selected
        ? (Theme.palette.accent ?? "transparent")
        : Qt.alpha(Theme.palette.surface ?? "black",
            area.containsMouse ? (Theme.opacities.full ?? 1) : 0)

    ChooserIcon {
        id: badge

        anchors.left: parent.left
        anchors.leftMargin: Metrics.gutter
        anchors.verticalCenter: parent.verticalCenter
        name: root.item.icon ?? ""
    }

    Column {
        anchors.left: badge.visible ? badge.right : parent.left
        anchors.leftMargin: Metrics.gutter
        anchors.right: marker.left
        anchors.rightMargin: Metrics.gutter
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.spacing.hair ?? 0

        Text {
            width: parent.width
            elide: Text.ElideRight
            text: root.item.label ?? ""
            color: root.labelColour
            font.family: Theme.fonts.ui ?? ""
            font.pixelSize: Theme.fontSizes.large ?? 0
            font.weight: Theme.fontWeights.medium ?? 0
        }

        Text {
            width: parent.width
            visible: this.text !== ""
            elide: Text.ElideRight
            text: root.item.subtitle ?? ""
            color: root.subtitleColour
            font.family: Theme.fonts.ui ?? ""
            font.pixelSize: Theme.fontSizes.normal ?? 0
        }
    }

    Text {
        id: marker

        anchors.right: parent.right
        anchors.rightMargin: Metrics.gutter
        anchors.verticalCenter: parent.verticalCenter
        visible: root.item.current ?? false
        text: "●"
        color: root.labelColour
        font.family: Theme.fonts.mono ?? ""
        font.pixelSize: Theme.fontSizes.large ?? 0
    }

    MouseArea {
        id: area

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: root.activated()
        onEntered: root.entered()
    }
}
