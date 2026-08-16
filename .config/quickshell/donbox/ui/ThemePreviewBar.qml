import QtQuick

Rectangle {
    id: root

    required property ThemePreviewScheme scheme

    readonly property real barShare: 0.62
    readonly property real pillShare: 0.42
    readonly property real activePillStretch: 2.4

    readonly property int pillHeight:
        Math.round(root.height * root.pillShare)

    readonly property var pills: [
        {
            stretch: root.activePillStretch,
            tint: root.scheme.accent
        },
        { stretch: 1, tint: root.scheme.surface },
        { stretch: 1, tint: root.scheme.surface }
    ]

    implicitHeight: Math.round(
        (root.scheme.sizes.barHeight ?? 0) * root.barShare)
    color: root.scheme.bgAlt
    radius: root.scheme.radii.normal ?? 0

    Row {
        anchors.left: parent.left
        anchors.leftMargin: root.scheme.spacing.tight ?? 0
        anchors.verticalCenter: parent.verticalCenter
        spacing: root.scheme.spacing.hair ?? 0

        Repeater {
            model: root.pills

            Rectangle {
                required property var modelData

                width: Math.round(
                    root.pillHeight * this.modelData.stretch)
                height: root.pillHeight
                radius: root.scheme.radii.round ?? 0
                color: this.modelData.tint
            }
        }
    }

    Text {
        anchors.right: parent.right
        anchors.rightMargin: root.scheme.spacing.tight ?? 0
        anchors.verticalCenter: parent.verticalCenter
        elide: Text.ElideRight
        text: root.scheme.name
        color: root.scheme.fg
        font.family: root.scheme.ui
        font.pixelSize: root.scheme.fontSizes.small ?? 0
        font.weight: root.scheme.fontWeights.medium ?? 0
    }
}
