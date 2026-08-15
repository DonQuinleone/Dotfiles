import QtQuick
import qs.services

SettingsRow {
    id: root

    required property int minutes
    required property int earliestMinutes
    required property int latestMinutes

    signal moved(int wanted)

    SettingsStepper {
        width: parent.width
        value: root.minutes
        minimum: root.earliestMinutes
        maximum: root.latestMinutes
        step: NightShift.clockStepMinutes
        readout: NightShift.clockText(this.value)

        onMoved: wanted => root.moved(wanted)
    }
}
