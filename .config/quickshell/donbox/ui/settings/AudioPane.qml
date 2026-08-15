import QtQuick
import qs.services

Column {
    id: root

    readonly property var directions: [
        {
            kind: AudioDevices.outputKind,
            title: qsTr("Output"),
            volumeLabel: qsTr("Volume"),
            volumeHint: qsTr("How loud everything this machine "
                + "plays is."),
            muteLabel: qsTr("Sound"),
            muteHint: qsTr("Muting silences the output without "
                + "losing the volume you set."),
            liveWord: qsTr("Playing"),
            mutedWord: qsTr("Muted"),
            chooseLabel: qsTr("Play sound through"),
            keepLabel: qsTr("Use this output"),
            absentNote: qsTr("Nothing is playing sound yet."),
            emptyNote: qsTr("No output device is available.")
        },
        {
            kind: AudioDevices.inputKind,
            title: qsTr("Input"),
            volumeLabel: qsTr("Microphone level"),
            volumeHint: qsTr("How loud the microphone sounds to "
                + "the applications recording it."),
            muteLabel: qsTr("Microphone"),
            muteHint: qsTr("Muting stops applications hearing "
                + "anything at all."),
            liveWord: qsTr("Listening"),
            mutedWord: qsTr("Muted"),
            chooseLabel: qsTr("Record from"),
            keepLabel: qsTr("Use this input"),
            absentNote: qsTr("No microphone is in use yet."),
            emptyNote: qsTr("No input device is available.")
        }
    ]

    spacing: Theme.spacing.loose ?? 0

    Repeater {
        model: root.directions

        AudioDirectionCard {
            required property var modelData

            width: root.width
            direction: this.modelData
        }
    }
}
