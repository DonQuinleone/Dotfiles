import QtQuick
import qs.services

Column {
    id: root

    spacing: Theme.spacing.loose ?? 0

    Text {
        visible: AudioStreams.playing.length === 0
        text: "Nothing is playing"
        color: Theme.palette.fgDim ?? "white"
        font.family: Theme.fonts.ui ?? ""
        font.pixelSize: Theme.fontSizes.normal ?? 0
    }

    Repeater {
        model: AudioStreams.playing

        AudioMixerRow {
            required property var modelData

            width: root.width
            title: AudioStreams.label(this.modelData)
            detail: AudioStreams.detail(this.modelData)
            level: AudioStreams.volume(this.modelData)
            muted: AudioStreams.muted(this.modelData)
            maximum: AudioStreams.loudest
            mark: AudioStreams.unityGain

            onMoved: wanted =>
                AudioStreams.setVolume(this.modelData, wanted)
            onMuteToggled: AudioStreams.toggleMute(this.modelData)
        }
    }
}
