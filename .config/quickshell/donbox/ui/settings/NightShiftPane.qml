import QtQuick
import qs.services

Column {
    id: root

    readonly property int temperatureStepKelvin: 50
    readonly property int shortestTransitionMinutes: 0
    readonly property int longestTransitionMinutes: 180
    readonly property int transitionStepMinutes: 15
    readonly property int readoutIntervalMs: 10000

    readonly property var overrideOptions: [
        { value: "auto", label: qsTr("Follow the schedule"),
          glyph: "󰃰" },
        { value: "on", label: qsTr("Warm now"), glyph: "󰖔" },
        { value: "off", label: qsTr("Neutral now"), glyph: "󰖙" }
    ]

    readonly property var scheduleOptions: [
        { value: false, label: qsTr("Follow the sun"),
          glyph: "󰖚" },
        { value: true, label: qsTr("Fixed times"), glyph: "󰥔" }
    ]

    spacing: Theme.spacing.loose ?? 0

    Component.onCompleted: NightShift.refresh()

    Timer {
        running: true
        repeat: true
        interval: root.readoutIntervalMs

        onTriggered: NightShift.refresh()
    }

    SettingsCard {
        width: parent.width
        title: qsTr("Right now")

        NightShiftReadout {
            width: parent.width
        }

        SettingsRow {
            width: parent.width
            label: qsTr("Warm the screen at night")
            hint: qsTr("With this off the screen keeps the day "
                + "temperature around the clock.")

            SettingsToggle {
                width: parent.width
                checked: NightShift.enabled

                onActivated: NightShift.setEnabled(
                    !NightShift.enabled)
            }
        }

        SettingsRow {
            width: parent.width
            visible: NightShift.enabled
            label: qsTr("For now")
            hint: qsTr("Warm and neutral hold until you choose "
                + "the schedule again.")

            SettingsChoice {
                width: parent.width
                options: root.overrideOptions
                current: NightShift.overrideMode

                onChosen: wanted => NightShift.setOverride(wanted)
            }
        }
    }

    SettingsCard {
        width: parent.width
        title: qsTr("Warmth")

        SettingsRow {
            width: parent.width
            label: qsTr("Night temperature")
            hint: qsTr("The warmest the screen goes once night "
                + "has fallen.")

            SettingsStepper {
                width: parent.width
                value: NightShift.nightTemperature
                minimum: NightShift.contrastFloorKelvin
                maximum: NightShift.dayTemperature
                step: root.temperatureStepKelvin
                readout: qsTr("%1 K").arg(this.value)

                onMoved: wanted =>
                    NightShift.setNightTemperature(wanted)
            }
        }

        SettingsNote {
            width: parent.width
            text: qsTr("%1 K is as warm as this goes. Warmer than "
                + "that and the theme colours stop clearing the "
                + "contrast every palette is checked against.")
                .arg(NightShift.contrastFloorKelvin)
        }

        SettingsRow {
            width: parent.width
            label: qsTr("Day temperature")
            hint: qsTr("The colour the screen returns to for the "
                + "rest of the day.")

            SettingsStepper {
                width: parent.width
                value: NightShift.dayTemperature
                minimum: NightShift.nightTemperature
                maximum: NightShift.neutralWhiteKelvin
                step: root.temperatureStepKelvin
                readout: qsTr("%1 K").arg(this.value)

                onMoved: wanted =>
                    NightShift.setDayTemperature(wanted)
            }
        }
    }

    SettingsCard {
        width: parent.width
        title: qsTr("Schedule")

        SettingsRow {
            width: parent.width
            label: qsTr("When night falls")
            hint: qsTr("The sun keeps pace with the seasons; "
                + "fixed times keep the same hours all year.")

            SettingsChoice {
                width: parent.width
                options: root.scheduleOptions
                current: NightShift.fixedTimes

                onChosen: wanted => NightShift.setFixedTimes(wanted)
            }
        }

        NightShiftClockRow {
            width: parent.width
            visible: NightShift.fixedTimes
            label: qsTr("Night begins")
            hint: qsTr("The evening time the screen starts "
                + "warming.")
            minutes: NightShift.nightStartMinutes
            earliestMinutes: NightShift.earliestNightStartMinutes
            latestMinutes: NightShift.latestNightStartMinutes

            onMoved: wanted => NightShift.setNightStart(wanted)
        }

        NightShiftClockRow {
            width: parent.width
            visible: NightShift.fixedTimes
            label: qsTr("Night ends")
            hint: qsTr("The morning time the screen returns to "
                + "the day temperature. It always falls before "
                + "night begins, because the night spans "
                + "midnight.")
            minutes: NightShift.nightEndMinutes
            earliestMinutes: NightShift.earliestNightEndMinutes
            latestMinutes: NightShift.latestNightEndMinutes

            onMoved: wanted => NightShift.setNightEnd(wanted)
        }

        SettingsRow {
            width: parent.width
            label: qsTr("Transition length")
            hint: qsTr("How long the screen takes to cross "
                + "between the two temperatures, half of it "
                + "before each change and half after.")

            SettingsStepper {
                width: parent.width
                value: NightShift.transitionMinutes
                minimum: root.shortestTransitionMinutes
                maximum: root.longestTransitionMinutes
                step: root.transitionStepMinutes
                readout: qsTr("%1 minutes").arg(this.value)

                onMoved: wanted => NightShift.setTransition(wanted)
            }
        }
    }
}
