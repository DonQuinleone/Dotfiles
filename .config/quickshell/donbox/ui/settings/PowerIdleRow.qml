import QtQuick
import qs.services

Item {
    id: root

    required property var step

    readonly property real delayShare: 0.4

    implicitHeight: Math.max(mark.implicitHeight,
        delay.implicitHeight, action.implicitHeight)

    Text {
        id: mark

        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        text: root.step.glyph
        color: Theme.palette.accent ?? "white"
        font.family: Theme.fonts.mono ?? ""
        font.pixelSize: Theme.sizes.iconNormal ?? 0
    }

    Text {
        id: delay

        anchors.left: mark.right
        anchors.leftMargin: Theme.spacing.tight ?? 0
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width * root.delayShare
        wrapMode: Text.WordWrap
        text: qsTr("After %1").arg(IdleProfile.spell(root.step.seconds))
        color: Theme.palette.fg ?? "white"
        font.family: Theme.fonts.ui ?? ""
        font.pixelSize: Theme.fontSizes.large ?? 0
        font.weight: Theme.fontWeights.medium ?? 0
    }

    Text {
        id: action

        anchors.left: delay.right
        anchors.right: parent.right
        anchors.leftMargin: Theme.spacing.normal ?? 0
        anchors.verticalCenter: parent.verticalCenter
        wrapMode: Text.WordWrap
        text: root.step.label
        color: Theme.palette.fgDim ?? "white"
        font.family: Theme.fonts.ui ?? ""
        font.pixelSize: Theme.fontSizes.normal ?? 0
    }
}
