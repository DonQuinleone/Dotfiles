import QtQuick
import qs.services

SettingsSurface {
    id: root

    required property var item
    required property bool selected
    required property bool focused

    signal activated

    readonly property string currentWord: qsTr("Current")

    height: Metrics.rowHeight
    highlighted: root.selected
    hovered: area.containsMouse

    Column {
        anchors.left: parent.left
        anchors.right: badge.left
        anchors.leftMargin: Theme.spacing.normal ?? 0
        anchors.rightMargin: Theme.spacing.tight ?? 0
        anchors.verticalCenter: parent.verticalCenter

        Text {
            width: parent.width
            elide: Text.ElideRight
            text: root.item.label
            color: root.ink
            font.family: Theme.fonts.ui ?? ""
            font.pixelSize: Theme.fontSizes.large ?? 0
            font.weight: Theme.fontWeights.medium ?? 0
        }

        Text {
            width: parent.width
            visible: (root.item.detail ?? "") !== ""
            elide: Text.ElideRight
            text: root.item.detail ?? ""
            color: root.ink
            opacity: Theme.opacities.muted ?? 1
            font.family: Theme.fonts.mono ?? ""
            font.pixelSize: Theme.fontSizes.small ?? 0
        }
    }

    Text {
        id: badge

        anchors.right: parent.right
        anchors.rightMargin: Theme.spacing.normal ?? 0
        anchors.verticalCenter: parent.verticalCenter
        visible: root.item.current ?? false
        text: root.currentWord
        color: root.ink
        font.family: Theme.fonts.ui ?? ""
        font.pixelSize: Theme.fontSizes.normal ?? 0
        font.weight: Theme.fontWeights.bold ?? 0
    }

    MouseArea {
        id: area

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: root.activated()
    }
}
