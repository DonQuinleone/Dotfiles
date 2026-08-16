import QtQuick

Item {
    id: root

    required property ThemePreviewScheme scheme

    readonly property real swatchShare: 0.7

    readonly property var tints: Object.values(root.scheme.accents)

    readonly property int gap: root.scheme.spacing.hair ?? 0

    readonly property int span: Math.max(1, root.tints.length)

    readonly property int swatchSize: Math.min(
        Math.round((root.scheme.sizes.iconNormal ?? 0)
            * root.swatchShare),
        Math.floor((root.width - root.gap * (root.span - 1))
            / root.span))

    implicitHeight: root.swatchSize

    Row {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: root.gap

        Repeater {
            model: root.tints

            Rectangle {
                required property color modelData

                width: root.swatchSize
                height: root.swatchSize
                radius: root.scheme.radii.small ?? 0
                color: this.modelData
            }
        }
    }
}
