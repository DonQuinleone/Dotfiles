import QtQuick
import qs.services

BarPill {
    id: root

    readonly property string heldLabel: "TALK"
    readonly property string latchedLabel: "LATCHED"
    readonly property real restingPulse: 0.55

    // The animation keeps its last value once it stops, so the
    // pill reads it only while it is the one breathing.
    property real pulse: Theme.opacities.full ?? 1

    visible: PushToTalk.live
    opacity: PushToTalk.latched
        ? root.pulse
        : (Theme.opacities.full ?? 1)
    color: Theme.palette.accent ?? "transparent"
    border.color: Theme.palette.accent ?? "transparent"

    content: [
        PillText {
            text: PushToTalk.glyph
            color: Theme.onAccent
            font.pixelSize: Theme.sizes.iconNormal ?? 0
        },
        PillText {
            text: PushToTalk.latched
                ? root.latchedLabel
                : root.heldLabel
            color: Theme.onAccent
            font.pixelSize: Theme.fontSizes.small ?? 0
            font.letterSpacing: Theme.spacing.hair ?? 0
        }
    ]

    // A held key speaks for itself; a latch is the one that can
    // be forgotten, so only that one breathes.
    SequentialAnimation on pulse {
        running: PushToTalk.latched && !Theme.reduceMotion
        loops: Animation.Infinite
        alwaysRunToEnd: true

        NumberAnimation {
            to: root.restingPulse
            duration: Theme.duration("flash")
            easing.type: Theme.easing("standard")
        }

        NumberAnimation {
            to: Theme.opacities.full ?? 1
            duration: Theme.duration("flash")
            easing.type: Theme.easing("standard")
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onClicked: PushToTalk.toggle()
    }
}
