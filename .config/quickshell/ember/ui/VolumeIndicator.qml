import QtQuick
import Quickshell.Services.Pipewire
import qs.services

BarPill {
    id: root

    readonly property real step: 0.05
    readonly property real minimum: 0.0
    readonly property real maximum: 1.0

    readonly property var levels: [
        { floor: 0.66, glyph: "󰕾" },
        { floor: 0.33, glyph: "󰖀" },
        { floor: 0.0, glyph: "󰕿" }
    ]

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property bool muted: root.sink?.audio?.muted ?? true
    readonly property real volume: root.sink?.audio?.volume ?? 0

    readonly property string glyph: {
        if (root.muted) return "󰝟";
        return root.levels
            .find(level => root.volume >= level.floor).glyph;
    }

    readonly property color tint: root.muted
        ? (Theme.palette.fgDim ?? "white")
        : (Theme.palette.fg ?? "white")

    visible: root.sink !== null

    function nudge(delta: real): void {
        if (!root.sink?.audio) return;
        root.sink.audio.volume = Math.max(root.minimum,
            Math.min(root.maximum, root.volume + delta));
    }

    content: [
        PillText {
            text: root.glyph
            color: root.tint
            font.pixelSize: Theme.sizes.iconNormal ?? 0
        },
        PillText {
            text: `${Math.round(root.volume * 100)}%`
            color: root.tint
        }
    ]

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onClicked: if (root.sink?.audio)
            root.sink.audio.muted = !root.muted
        onWheel: wheel => root.nudge(wheel.angleDelta.y > 0
            ? root.step : -root.step)
    }
}
