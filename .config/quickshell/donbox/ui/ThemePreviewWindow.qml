import QtQuick

Rectangle {
    id: root

    required property ThemePreviewScheme scheme
    required property string caption

    readonly property real lightShare: 0.3

    readonly property int lightSize: Math.round(
        (root.scheme.sizes.iconNormal ?? 0) * root.lightShare)

    readonly property var lights: [
        root.scheme.bad, root.scheme.warn, root.scheme.good
    ]

    readonly property var lines: [
        {
            words: root.scheme.ui,
            face: root.scheme.ui,
            ink: root.scheme.fg,
            size: root.scheme.fontSizes.normal ?? 0
        },
        {
            words: root.scheme.mono,
            face: root.scheme.mono,
            ink: root.scheme.fgDim,
            size: root.scheme.fontSizes.small ?? 0
        }
    ]

    readonly property var readoutKeys:
        ["accent", "good", "warn", "bad"]

    readonly property var readout: root.readoutKeys.map(key => ({
        label: key,
        tint: root.scheme.palette[key] ?? root.scheme.fg
    }))

    color: root.scheme.bgAlt
    radius: root.scheme.radii.normal ?? 0
    border.width: root.scheme.sizes.borderWidth ?? 0
    border.color: root.scheme.border
    clip: true

    Row {
        id: titleBar

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: root.scheme.spacing.tight ?? 0
        spacing: root.scheme.spacing.hair ?? 0

        Repeater {
            model: root.lights

            Rectangle {
                required property color modelData

                anchors.verticalCenter: parent.verticalCenter
                width: root.lightSize
                height: root.lightSize
                radius: root.scheme.radii.round ?? 0
                color: this.modelData
            }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            leftPadding: root.scheme.spacing.tight ?? 0
            elide: Text.ElideRight
            text: root.caption
            color: root.scheme.fgDim
            font.family: root.scheme.mono
            font.pixelSize: root.scheme.fontSizes.small ?? 0
        }
    }

    Column {
        anchors.top: titleBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: root.scheme.spacing.tight ?? 0
        spacing: root.scheme.spacing.hair ?? 0

        Repeater {
            model: root.lines

            Text {
                required property var modelData

                width: parent.width
                elide: Text.ElideRight
                text: this.modelData.words
                color: this.modelData.ink
                font.family: this.modelData.face
                font.pixelSize: this.modelData.size
            }
        }
    }

    Column {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: root.scheme.spacing.tight ?? 0
        spacing: root.scheme.spacing.hair ?? 0

        Repeater {
            model: root.readout

            ThemePreviewColourRow {
                required property var modelData

                width: parent.width
                scheme: root.scheme
                label: this.modelData.label
                tint: this.modelData.tint
            }
        }
    }
}
