pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Services.UPower

Singleton {
    id: root

    readonly property int maxListedDevices: 4
    readonly property real unknownLevel: -1

    readonly property string offGlyph: "󰂲"
    readonly property string idleGlyph: "󰂯"
    readonly property string linkedGlyph: "󰂱"

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool available: root.adapter !== null
    readonly property bool powered: root.adapter?.enabled ?? false
    readonly property string adapterName: root.adapter?.name ?? ""

    readonly property bool scanning: root.adapter?.discovering ?? false

    readonly property bool discoverable:
        root.adapter?.discoverable ?? false

    readonly property int discoverableSeconds:
        root.adapter?.discoverableTimeout ?? 0

    readonly property var devices: Bluetooth.devices?.values ?? []

    readonly property var linked:
        root.devices.filter(device => device.connected)

    readonly property var paired: root.devices
        .filter(device => root.isPaired(device))
        .sort((first, second) =>
            Number(second.connected) - Number(first.connected)
            || first.name.localeCompare(second.name))

    readonly property var known:
        root.paired.slice(0, root.maxListedDevices)

    readonly property var nearby: root.devices
        .filter(device => !root.isPaired(device))
        .sort((first, second) => first.name.localeCompare(second.name))

    readonly property int linkedCount: root.linked.length

    // BlueZ only reports a level for peripherals implementing the
    // battery service; UPower picks up the rest over HID, keyed by
    // the Bluetooth address in its native path.
    readonly property var peripherals: (UPower.devices?.values ?? [])
        .filter(device => device.ready && device.isPresent
            && !device.isLaptopBattery)

    readonly property var readings: root.linked
        .map(device => ({
            name: device.name,
            level: root.levelOf(device)
        }))
        .filter(reading => reading.level >= 0)
        .sort((first, second) => first.level - second.level)

    readonly property var lowestReading: root.readings[0] ?? null

    readonly property int lowestPercent: root.lowestReading
        ? Math.round(root.lowestReading.level * 100)
        : 0

    readonly property bool batteryLow: root.lowestReading !== null
        && Battery.low(root.lowestPercent)

    readonly property string glyph: {
        if (!root.powered) return root.offGlyph;
        if (root.linkedCount > 0) return root.linkedGlyph;
        return root.idleGlyph;
    }

    readonly property string label: {
        if (!root.powered) return "Bluetooth off";
        if (root.linkedCount === 0) return "Nothing connected";
        if (root.linkedCount === 1) return root.linked[0].name;
        return `${root.linkedCount} devices`;
    }

    readonly property color tint: {
        if (!root.powered) return Theme.palette.fgDim ?? "white";
        if (root.linkedCount > 0) return Theme.palette.fg ?? "white";
        return Theme.palette.fgDim ?? "white";
    }

    function isPaired(device: var): bool {
        return device.paired || device.bonded;
    }

    function peripheralFor(address: string): var {
        const key = address.toLowerCase();
        return root.peripherals.find(device =>
            device.nativePath.toLowerCase().includes(key)) ?? null;
    }

    function levelOf(device: var): real {
        if (device.batteryAvailable) return device.battery;
        const peripheral = root.peripheralFor(device.address);
        if (!peripheral) return root.unknownLevel;
        return peripheral.percentage;
    }

    function reports(device: var): bool {
        return root.levelOf(device) >= 0;
    }

    function percentOf(device: var): int {
        return Math.round(root.levelOf(device) * 100);
    }

    function batteryLabel(device: var): string {
        if (!root.reports(device)) return "";
        return `${root.percentOf(device)}%`;
    }

    function statusOf(device: var): string {
        if (device.pairing) return "Pairing";
        if (device.connected) return "Connected";
        if (!root.isPaired(device)) return "Not paired";
        return "Paired";
    }

    function togglePower(): void {
        if (!root.adapter) return;
        root.adapter.enabled = !root.adapter.enabled;
    }

    function toggleScanning(): void {
        if (!root.adapter) return;
        root.adapter.discovering = !root.adapter.discovering;
    }

    function toggleDiscoverable(): void {
        if (!root.adapter) return;
        root.adapter.discoverable = !root.adapter.discoverable;
    }

    function toggleLink(device: var): void {
        if (device.connected) {
            device.disconnect();
            return;
        }
        device.connect();
    }

    function togglePairing(device: var): void {
        if (device.pairing) {
            device.cancelPair();
            return;
        }
        device.pair();
    }

    function toggleTrust(device: var): void {
        device.trusted = !device.trusted;
    }

    function forget(device: var): void {
        device.forget();
    }
}
