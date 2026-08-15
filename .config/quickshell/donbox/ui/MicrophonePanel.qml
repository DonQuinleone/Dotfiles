import QtQuick
import qs.services

PanelSurface {
    id: root

    readonly property string kind: AudioDevices.inputKind

    readonly property bool muted: AudioDevices.muted(root.kind)

    PanelHeadline {
        width: parent.width
        text: root.muted ? "Microphone muted" : "Microphone live"
        color: root.muted
            ? (Theme.palette.fgDim ?? "white")
            : (Theme.palette.good ?? "white")
    }

    AudioMixerRow {
        width: parent.width
        visible: AudioDevices.present(root.kind)
        title: "Input level"
        detail: AudioDevices.currentLabel(root.kind)
        level: AudioDevices.volume(root.kind)
        muted: root.muted
        maximum: AudioDevices.loudest
        liveGlyph: "󰍬"
        mutedGlyph: "󰍭"

        onMoved: wanted => AudioDevices.setVolume(root.kind, wanted)
        onMuteToggled: AudioDevices.toggleMute(root.kind)
    }

    QuickSection {
        width: parent.width
        title: "Record sound from"

        AudioDeviceList {
            width: parent.width
            kind: root.kind
        }
    }
}
