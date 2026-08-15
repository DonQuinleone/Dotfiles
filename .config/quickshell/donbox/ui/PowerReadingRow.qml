import QtQuick
import qs.services

Item {
    id: root

    required property string label
    required property string reading

    implicitHeight: Math.max(name.implicitHeight,
        figure.implicitHeight)

    Text {
        id: name

        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        text: root.label
        color: Theme.palette.fgDim ?? "white"
        font.family: Theme.fonts.ui ?? ""
        font.pixelSize: Theme.fontSizes.normal ?? 0
    }

    Text {
        id: figure

        anchors.left: name.right
        anchors.leftMargin: Theme.spacing.normal ?? 0
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        horizontalAlignment: Text.AlignRight
        elide: Text.ElideRight
        text: root.reading
        color: Theme.palette.fg ?? "white"
        font.family: Theme.fonts.ui ?? ""
        font.pixelSize: Theme.fontSizes.normal ?? 0
        font.weight: Theme.fontWeights.medium ?? 0
    }
}
