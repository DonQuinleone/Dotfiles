import QtQuick
import qs.services

Item {
    id: root

    required property var binding

    readonly property string words: root.binding.description !== ""
        ? root.binding.description
        : root.binding.detail

    implicitHeight: Math.max(combo.implicitHeight,
        said.implicitHeight)

    Text {
        id: combo

        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width / 2
        wrapMode: Text.WordWrap
        text: root.binding.combo
        color: Theme.palette.accent ?? "white"
        font.family: Theme.fonts.mono ?? ""
        font.pixelSize: Theme.fontSizes.large ?? 0
        font.weight: Theme.fontWeights.bold ?? 0
    }

    Text {
        id: said

        anchors.left: combo.right
        anchors.right: parent.right
        anchors.leftMargin: Theme.spacing.normal ?? 0
        anchors.verticalCenter: parent.verticalCenter
        wrapMode: Text.WordWrap
        text: root.words
        color: Theme.palette.fg ?? "white"
        font.family: Theme.fonts.ui ?? ""
        font.pixelSize: Theme.fontSizes.normal ?? 0
    }
}
