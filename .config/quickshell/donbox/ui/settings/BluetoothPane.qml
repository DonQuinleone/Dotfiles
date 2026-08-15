import QtQuick
import qs.services

Column {
    id: root

    readonly property string visibilityHint:
        BluetoothRadio.discoverableSeconds > 0
            ? qsTr("Other devices can find this computer for %1 "
                + "seconds at a time.")
                .arg(BluetoothRadio.discoverableSeconds)
            : qsTr("Other devices can find this computer until "
                + "this is turned off.")

    spacing: Theme.spacing.loose ?? 0

    SettingsCard {
        width: parent.width
        title: qsTr("Bluetooth")

        SettingsNote {
            width: parent.width
            text: BluetoothRadio.available
                ? qsTr("Adapter %1. %2.")
                    .arg(BluetoothRadio.adapterName)
                    .arg(BluetoothRadio.label)
                : qsTr("No Bluetooth adapter is switched on or "
                    + "plugged in.")
        }

        SettingsRow {
            width: parent.width
            visible: BluetoothRadio.available
            label: qsTr("Bluetooth radio")
            hint: qsTr("Turning the radio off drops every device "
                + "that is connected.")

            SettingsToggle {
                width: parent.width
                checked: BluetoothRadio.powered

                onActivated: BluetoothRadio.togglePower()
            }
        }
    }

    SettingsCard {
        width: parent.width
        visible: BluetoothRadio.powered
        title: qsTr("Finding devices")

        SettingsRow {
            width: parent.width
            label: qsTr("Search for devices")
            hint: qsTr("Keeps looking until it is turned off, "
                + "which uses more battery.")

            SettingsToggle {
                width: parent.width
                checked: BluetoothRadio.scanning
                onWord: qsTr("Searching")
                offWord: qsTr("Not searching")

                onActivated: BluetoothRadio.toggleScanning()
            }
        }

        SettingsRow {
            width: parent.width
            label: qsTr("Visible to other devices")
            hint: root.visibilityHint

            SettingsToggle {
                width: parent.width
                checked: BluetoothRadio.discoverable
                onWord: qsTr("Visible")
                offWord: qsTr("Hidden")

                onActivated: BluetoothRadio.toggleDiscoverable()
            }
        }
    }

    SettingsCard {
        width: parent.width
        visible: BluetoothRadio.available
        title: qsTr("Paired devices")

        SettingsNote {
            width: parent.width
            visible: BluetoothRadio.paired.length === 0
            text: qsTr("Nothing is paired yet. Search for devices "
                + "to add one.")
        }

        Repeater {
            model: BluetoothRadio.paired

            BluetoothDeviceRow {
                required property var modelData

                width: parent.width
                device: this.modelData
            }
        }
    }

    SettingsCard {
        width: parent.width
        visible: BluetoothRadio.powered
            && (BluetoothRadio.scanning
                || BluetoothRadio.nearby.length > 0)
        title: qsTr("Devices nearby")

        SettingsNote {
            width: parent.width
            text: qsTr("Pairing here cannot show a passkey, so a "
                + "device that asks for one has to be paired with "
                + "bluetoothctl.")
        }

        SettingsNote {
            width: parent.width
            visible: BluetoothRadio.nearby.length === 0
            text: qsTr("Searching. Put the other device into "
                + "pairing mode so that it can be seen.")
        }

        Repeater {
            model: BluetoothRadio.nearby

            BluetoothDeviceRow {
                required property var modelData

                width: parent.width
                device: this.modelData
            }
        }
    }
}
