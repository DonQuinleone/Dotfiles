import QtQuick
import qs.services

SettingsCard {
    id: root

    required property var device

    readonly property string name: root.device.name

    readonly property real speedMinimum: -1.0
    readonly property real speedMaximum: 1.0
    readonly property real speedIncrement: 0.05
    readonly property real scrollMinimum: 0.1
    readonly property real scrollMaximum: 3.0
    readonly property real scrollIncrement: 0.1
    readonly property int figureDigits: 2

    title: InputDevices.title(root.name)

    function readout(field: string, figure: real): string {
        const shown = figure.toFixed(root.figureDigits);
        if (InputDevices.overridden(root.name, field)) return shown;
        return qsTr("%1 (default)").arg(shown);
    }

    SettingsNote {
        width: parent.width
        text: root.device.connected
            ? root.name
            : qsTr("%1 (not connected)").arg(root.name)
    }

    SettingsRow {
        width: parent.width
        label: qsTr("Pointer speed")
        hint: qsTr("From -1.00 for the slowest to 1.00 for the "
            + "fastest.")

        SettingsStepper {
            width: parent.width
            value: InputDevices.value(root.name, "sensitivity")
            minimum: root.speedMinimum
            maximum: root.speedMaximum
            step: root.speedIncrement
            readout: root.readout("sensitivity", this.value)

            onMoved: wanted => InputDevices.set(
                root.name, "sensitivity", wanted)
        }
    }

    SettingsRow {
        width: parent.width
        label: qsTr("Scroll speed")
        hint: qsTr("Multiplies how far one scroll gesture travels.")

        SettingsStepper {
            width: parent.width
            value: InputDevices.value(root.name, "scrollFactor")
            minimum: root.scrollMinimum
            maximum: root.scrollMaximum
            step: root.scrollIncrement
            readout: root.readout("scrollFactor", this.value)

            onMoved: wanted => InputDevices.set(
                root.name, "scrollFactor", wanted)
        }
    }

    SettingsRow {
        width: parent.width
        label: qsTr("Natural scrolling")
        hint: qsTr("The content follows the fingers rather than the "
            + "view.")

        SettingsToggle {
            width: parent.width
            checked: InputDevices.value(root.name, "naturalScroll")

            onActivated: InputDevices.set(root.name, "naturalScroll",
                !InputDevices.value(root.name, "naturalScroll"))
        }
    }

    SettingsRow {
        width: parent.width
        label: qsTr("Tap to click")
        hint: qsTr("A tap counts as a click, without pressing the "
            + "surface down.")

        SettingsToggle {
            width: parent.width
            checked: InputDevices.value(root.name, "tapToClick")

            onActivated: InputDevices.set(root.name, "tapToClick",
                !InputDevices.value(root.name, "tapToClick"))
        }
    }

    SettingsButton {
        label: qsTr("Use the system defaults")
        glyph: "󰦛"

        onActivated: InputDevices.reset(root.name)
    }
}
