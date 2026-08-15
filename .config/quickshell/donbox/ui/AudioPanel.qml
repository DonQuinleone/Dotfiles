import QtQuick
import qs.services

PanelSurface {
    id: root

    readonly property string kind: AudioDevices.outputKind

    AudioMixerRow {
        width: parent.width
        visible: AudioDevices.present(root.kind)
        title: "Output"
        detail: AudioDevices.currentLabel(root.kind)
        level: AudioDevices.volume(root.kind)
        muted: AudioDevices.muted(root.kind)
        maximum: AudioDevices.loudest

        onMoved: wanted => AudioDevices.setVolume(root.kind, wanted)
        onMuteToggled: AudioDevices.toggleMute(root.kind)
    }

    QuickSection {
        width: parent.width
        title: "Applications"

        AudioStreamList {
            width: parent.width
        }
    }

    QuickSection {
        width: parent.width
        title: "Play sound through"

        AudioDeviceList {
            width: parent.width
            kind: root.kind
        }
    }
}
