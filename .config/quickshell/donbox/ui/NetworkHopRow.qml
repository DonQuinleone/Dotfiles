import QtQuick
import qs.services

Item {
    id: root

    required property var probe

    readonly property int gap: Theme.spacing.tight ?? 0

    readonly property color tint: {
        if (!root.probe.sampled) return Theme.palette.fgDim ?? "white";
        if (!root.probe.reachable) return Theme.palette.bad ?? "white";
        if (root.probe.lossPercent > 0) {
            return Theme.palette.warn ?? "white";
        }
        return Theme.palette.good ?? "white";
    }

    implicitHeight: Math.max(
        name.implicitHeight, reading.implicitHeight)

    Text {
        id: name

        anchors.left: parent.left
        anchors.right: reading.left
        anchors.rightMargin: root.gap
        anchors.verticalCenter: parent.verticalCenter
        elide: Text.ElideRight
        text: root.probe.label
        color: Theme.palette.fg ?? "white"
        font.family: Theme.fonts.ui ?? ""
        font.pixelSize: Theme.fontSizes.normal ?? 0
    }

    Row {
        id: reading

        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: root.gap

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.probe.latencyText
            color: root.tint
            font.family: Theme.fonts.mono ?? ""
            font.pixelSize: Theme.fontSizes.normal ?? 0
            font.weight: Theme.fontWeights.medium ?? 0
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.probe.lossText !== ""
            text: root.probe.lossText
            color: Theme.palette.fgDim ?? "white"
            font.family: Theme.fonts.mono ?? ""
            font.pixelSize: Theme.fontSizes.small ?? 0
        }
    }
}
