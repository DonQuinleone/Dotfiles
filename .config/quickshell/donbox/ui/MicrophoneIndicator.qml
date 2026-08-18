import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import qs.services

BarPill {
    id: root

    readonly property string liveGlyph: "󰍬"
    readonly property string mutedGlyph: "󰍭"

    readonly property PwNode source: Pipewire.defaultAudioSource
    readonly property bool muted: root.source?.audio?.muted ?? true

    highlighted: panel.visible
    visible: root.source !== null

    content: [
        PillText {
            text: root.muted ? root.mutedGlyph : root.liveGlyph
            color: root.muted
                ? (Theme.palette.fgDim ?? "white")
                : (Theme.palette.fg ?? "white")
            font.pixelSize: Theme.sizes.iconNormal ?? 0
        }
    ]

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSource]
    }

    PanelToggle {
        surface: panel
    }

    MicrophonePanel {
        id: panel

        name: "microphone"

        under: root
    }
}
