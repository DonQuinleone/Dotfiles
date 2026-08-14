import QtQuick
import qs.services

Column {
    id: root

    spacing: Theme.spacing.loose ?? 0

    SettingsCard {
        width: parent.width
        title: qsTr("Pointing devices")

        SettingsNote {
            width: parent.width
            text: qsTr("Read from the compositor. A device keeps "
                + "its settings while it is unplugged.")
        }

        SettingsButton {
            label: qsTr("Look again")
            glyph: "󰑐"

            onActivated: InputDevices.refresh()
        }
    }

    Repeater {
        model: InputDevices.rows

        DeviceCard {
            required property var modelData

            width: root.width
            device: this.modelData
        }
    }

    SettingsCard {
        width: parent.width
        title: qsTr("Keyboards")

        Repeater {
            model: InputDevices.keyboards

            SettingsNote {
                required property var modelData

                width: parent.width
                text: qsTr("%1, laid out as %2")
                    .arg(this.modelData.name)
                    .arg(this.modelData.active_keymap)
            }
        }
    }
}
