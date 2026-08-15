import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import qs.services

BarPill {
    id: root

    readonly property real step: 0.05
    readonly property real quietest: 0.0
    readonly property real loudest: 1.0

    readonly property string speakerGlyph: "󰕾"
    readonly property string mutedGlyph: "󰖁"

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property bool muted: root.sink?.audio?.muted ?? true
    readonly property real volume: root.sink?.audio?.volume ?? 0

    visible: root.sink !== null
    highlighted: panel.visible

    function nudge(delta: real): void {
        if (!root.sink?.audio) return;
        root.sink.audio.volume = Math.max(root.quietest,
            Math.min(root.loudest, root.volume + delta));
    }

    content: [
        PillText {
            text: root.muted ? root.mutedGlyph : root.speakerGlyph
            color: root.muted
                ? (Theme.palette.fgDim ?? "white")
                : (Theme.palette.fg ?? "white")
            font.pixelSize: Theme.sizes.iconNormal ?? 0
        }
    ]

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    PanelToggle {
        name: "audio"
        surface: panel

        onWheel: wheel => root.nudge(wheel.angleDelta.y > 0
            ? root.step : -root.step)
    }

    AudioPanel {
        id: panel

        anchor.item: root
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom
    }
}
