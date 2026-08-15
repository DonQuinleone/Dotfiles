import QtQuick
import qs.services

PanelSurface {
    id: root

    readonly property var devices: BluetoothRadio.paired

    function statusOf(device: var): string {
        const state = BluetoothRadio.statusOf(device);
        const level = BluetoothRadio.batteryLabel(device);
        return level === "" ? state : `${state} · ${level}`;
    }

    function actionFor(device: var): string {
        return device.connected ? "Disconnect" : "Connect";
    }

    PanelHeadline {
        width: parent.width
        text: BluetoothRadio.label
    }

    QuickChip {
        label: BluetoothRadio.powered
            ? "Radio on"
            : "Radio off"
        glyph: BluetoothRadio.glyph
        selected: BluetoothRadio.powered

        onActivated: BluetoothRadio.togglePower()
    }

    QuickSection {
        width: parent.width
        visible: BluetoothRadio.powered
        title: "Devices"

        PanelEmpty {
            width: parent.width
            visible: root.devices.length === 0
            text: "Nothing is paired yet. Pair a device in "
                + "settings first."
        }

        Repeater {
            model: root.devices

            PanelRow {
                required property var modelData

                width: parent.width
                glyph: BluetoothRadio.glyph
                title: this.modelData.name
                status: root.statusOf(this.modelData)
                actionLabel: root.actionFor(this.modelData)
                actionOffered: true
                current: this.modelData.connected

                onChosen: BluetoothRadio.toggleLink(this.modelData)
            }
        }
    }
}
