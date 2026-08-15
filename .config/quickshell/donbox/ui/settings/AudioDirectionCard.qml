import QtQuick
import qs.services

SettingsCard {
    id: root

    required property var direction

    readonly property string kind: root.direction.kind
    readonly property var rows: AudioDevices.rows(root.kind)
    readonly property bool present: AudioDevices.present(root.kind)
    readonly property bool listed: root.rows.length > 0

    readonly property string chooseHint: qsTr("Up and Down move "
        + "through the list. Nothing switches until you press "
        + "Enter or the button below.")

    title: root.direction.title

    onRowsChanged: list.locate(
        AudioDevices.inUse(root.kind)?.id ?? AudioDevices.noDevice)

    SettingsNote {
        width: parent.width
        visible: !root.present && root.listed
        text: root.direction.absentNote
    }

    SettingsRow {
        width: parent.width
        visible: root.present
        label: root.direction.volumeLabel
        hint: root.direction.volumeHint

        SettingsStepper {
            width: parent.width
            value: AudioDevices.volume(root.kind)
            minimum: AudioDevices.quietest
            maximum: AudioDevices.loudest
            step: Levels.step
            readout: Levels.readout(Levels.volumeWords, this.value)

            onMoved: wanted =>
                AudioDevices.setVolume(root.kind, wanted)
        }
    }

    SettingsRow {
        width: parent.width
        visible: root.present
        label: root.direction.muteLabel
        hint: root.direction.muteHint

        SettingsToggle {
            width: parent.width
            checked: !AudioDevices.muted(root.kind)
            onWord: root.direction.liveWord
            offWord: root.direction.mutedWord

            onActivated: AudioDevices.toggleMute(root.kind)
        }
    }

    SettingsRow {
        width: parent.width
        visible: root.listed
        label: root.direction.chooseLabel
        hint: root.chooseHint

        SettingsList {
            id: list

            width: parent.width
            items: root.rows

            onChosen: wanted => AudioDevices.use(root.kind, wanted)
        }
    }

    SettingsButton {
        visible: root.listed
        label: root.direction.keepLabel
        glyph: "󰄬"

        onActivated: AudioDevices.use(root.kind,
            root.rows[list.index]?.value ?? AudioDevices.noDevice)
    }

    SettingsNote {
        width: parent.width
        visible: !root.listed
        text: root.direction.emptyNote
    }
}
