import QtQuick
import qs.services

Item {
    id: root

    required property string label
    required property string value

    visible: root.value !== ""
    implicitHeight: Math.max(caption.implicitHeight,
        figure.implicitHeight)

    Text {
        id: caption

        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        text: root.label
        color: Theme.palette.fgDim ?? "white"
        font.family: Theme.fonts.ui ?? ""
        font.pixelSize: Theme.fontSizes.large ?? 0
        font.weight: Theme.fontWeights.medium ?? 0
    }

    Text {
        id: figure

        anchors.left: caption.right
        anchors.leftMargin: Theme.spacing.loose ?? 0
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        horizontalAlignment: Text.AlignRight
        elide: Text.ElideRight
        text: root.value
        color: Theme.palette.fg ?? "white"
        font.family: Theme.fonts.mono ?? ""
        font.pixelSize: Theme.fontSizes.display ?? 0
        font.weight: Theme.fontWeights.bold ?? 0
        font.features: ({ "tnum": 1 })
    }
}
