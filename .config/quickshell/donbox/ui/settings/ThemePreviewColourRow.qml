import QtQuick

Item {
    id: root

    required property ThemePreviewScheme scheme
    required property string label
    required property color tint

    readonly property real chipShare: 0.55

    readonly property int chipSize: Math.round(
        (root.scheme.sizes.iconNormal ?? 0) * root.chipShare)

    implicitHeight: Math.max(root.chipSize, name.implicitHeight)

    Row {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: root.scheme.spacing.tight ?? 0

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: root.chipSize
            height: root.chipSize
            radius: root.scheme.radii.small ?? 0
            color: root.tint
        }

        Text {
            id: name

            anchors.verticalCenter: parent.verticalCenter
            text: root.label
            color: root.scheme.fgDim
            font.family: root.scheme.mono
            font.pixelSize: root.scheme.fontSizes.small ?? 0
        }
    }

    Text {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        text: `${root.tint}`.toUpperCase()
        color: root.scheme.fg
        font.family: root.scheme.mono
        font.pixelSize: root.scheme.fontSizes.small ?? 0
    }
}
