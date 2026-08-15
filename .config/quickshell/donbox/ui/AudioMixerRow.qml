import QtQuick
import qs.services

Column {
    id: root

    required property string title
    required property real level
    required property bool muted

    property string detail: ""
    property real maximum: 1.0
    property real mark: 0.0

    property string mutedGlyph: "󰖁"
    property string liveGlyph: "󰕾"

    readonly property bool boosted:
        slider.marked && root.level > root.mark

    readonly property color tint: root.muted
        ? (Theme.palette.fgDim ?? "white")
        : (Theme.palette.accent ?? "white")

    readonly property int gap: Theme.spacing.tight ?? 0

    signal moved(real wanted)
    signal muteToggled

    spacing: Theme.spacing.hair ?? 0

    Item {
        width: parent.width
        height: Math.max(naming.implicitHeight, mute.implicitHeight)

        Column {
            id: naming

            anchors.left: parent.left
            anchors.right: readout.left
            anchors.rightMargin: root.gap
            anchors.verticalCenter: parent.verticalCenter

            Text {
                width: parent.width
                elide: Text.ElideRight
                text: root.title
                color: Theme.palette.fg ?? "white"
                font.family: Theme.fonts.ui ?? ""
                font.pixelSize: Theme.fontSizes.normal ?? 0
                font.weight: Theme.fontWeights.medium ?? 0
            }

            Text {
                width: parent.width
                visible: root.detail !== ""
                elide: Text.ElideRight
                text: root.detail
                color: Theme.palette.fgDim ?? "white"
                font.family: Theme.fonts.ui ?? ""
                font.pixelSize: Theme.fontSizes.small ?? 0
            }
        }

        Text {
            id: readout

            anchors.right: mute.left
            anchors.rightMargin: root.gap
            anchors.verticalCenter: parent.verticalCenter
            text: Levels.percent(root.level)
            color: root.boosted
                ? (Theme.palette.warn ?? "white")
                : (Theme.palette.fg ?? "white")
            font.family: Theme.fonts.mono ?? ""
            font.pixelSize: Theme.fontSizes.normal ?? 0
            font.weight: Theme.fontWeights.medium ?? 0
            font.features: ({ "tnum": 1 })
        }

        QuickChip {
            id: mute

            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            label: root.muted ? "Unmute" : "Mute"
            glyph: root.muted ? root.mutedGlyph : root.liveGlyph
            selected: root.muted

            onActivated: root.muteToggled()
        }
    }

    AudioSlider {
        id: slider

        width: parent.width
        value: root.level
        maximum: root.maximum
        mark: root.mark
        tint: root.tint

        onMoved: wanted => root.moved(wanted)
    }
}
