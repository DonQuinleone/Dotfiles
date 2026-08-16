import QtQuick
import qs.services

PanelSurface {
    id: root

    readonly property var devices: BluetoothRadio.paired
    readonly property var nearby: BluetoothRadio.nearby

    function statusOf(device: var): string {
        const state = BluetoothRadio.statusOf(device);
        const level = BluetoothRadio.batteryLabel(device);
        return level === "" ? state : `${state} · ${level}`;
    }

    function actionFor(device: var): string {
        return device.connected ? "Disconnect" : "Connect";
    }

    function pairingFor(device: var): string {
        return device.pairing ? "Cancel" : "Pair";
    }

    function scanNote(): string {
        if (!BluetoothRadio.scanning) return "Not scanning";
        return root.nearby.length === 0
            ? "Scanning..."
            : `Scanning, ${root.nearby.length} found`;
    }

    onVisibleChanged: {
        BluetoothRadio.setPairingMode(root.visible);
        if (root.visible) BluetoothRadio.readCells();
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
            text: "Nothing is paired yet. Anything in pairing "
                + "range is listed below."
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

    QuickSection {
        width: parent.width
        visible: BluetoothRadio.powered
        title: "Nearby"

        PanelEmpty {
            width: parent.width
            visible: root.nearby.length === 0
            text: root.scanNote()
        }

        Repeater {
            model: root.nearby

            PanelRow {
                required property var modelData

                width: parent.width
                glyph: BluetoothRadio.idleGlyph
                title: this.modelData.name
                status: BluetoothRadio.statusOf(this.modelData)
                actionLabel: root.pairingFor(this.modelData)
                actionOffered: true
                current: this.modelData.pairing

                onChosen: BluetoothRadio.togglePairing(this.modelData)
            }
        }
    }
}
