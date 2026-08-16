import QtQuick
import qs.services

Item {
    id: root

    required property var item
    required property bool selected

    signal activated

    readonly property string picture:
        (root.item.value ?? "").startsWith("/")
            ? `file://${root.item.value}`
            : ""

    implicitWidth: Metrics.cellWidth
    implicitHeight: Metrics.cellHeight

    Rectangle {
        anchors.fill: parent
        anchors.margins: Metrics.gutter
        radius: Theme.radii.normal ?? 0
        color: root.selected
            ? (Theme.palette.accent ?? "transparent")
            : (Theme.palette.surface ?? "transparent")
        border.width: Theme.sizes.borderWidth ?? 0
        border.color: root.selected || area.containsMouse
            ? (Theme.palette.accentSoft ?? "transparent")
            : (Theme.palette.border ?? "transparent")

        Image {
            id: preview

            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: Theme.sizes.borderWidth ?? 0
            height: Metrics.thumbnailHeight
            fillMode: Image.PreserveAspectCrop
            sourceSize.width: Metrics.thumbnailWidth
            asynchronous: true
            clip: true
            visible: root.picture !== ""
            source: root.picture
        }

        Rectangle {
            anchors.top: preview.top
            anchors.right: preview.right
            anchors.margins: Metrics.gutter
            visible: root.item.current ?? false
            implicitWidth: badge.implicitWidth + Metrics.gutter
            implicitHeight: badge.implicitHeight
                + (Theme.spacing.hair ?? 0) * 2
            radius: Theme.radii.round ?? 0
            color: Theme.palette.accent ?? "transparent"

            Text {
                id: badge

                anchors.centerIn: parent
                text: qsTr("Current")
                color: Theme.onAccent
                font.family: Theme.fonts.ui ?? ""
                font.pixelSize: Theme.fontSizes.small ?? 0
                font.weight: Theme.fontWeights.bold ?? 0
            }
        }

        Text {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: preview.bottom
            anchors.bottom: parent.bottom
            anchors.margins: Metrics.gutter
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideMiddle
            text: root.item.label ?? ""
            color: root.selected
                ? Theme.onAccent
                : (Theme.palette.fg ?? "white")
            font.family: Theme.fonts.ui ?? ""
            font.pixelSize: Theme.fontSizes.normal ?? 0
            font.weight: root.item.current
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
