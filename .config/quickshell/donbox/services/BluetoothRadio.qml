pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io
import Quickshell.Services.UPower

Singleton {
    id: root

    readonly property int maxListedDevices: 4
    readonly property real unknownLevel: -1

    // Every reading costs a GATT round trip that wakes the
    // peripheral, so this is slow on purpose; the pane asks for
    // a fresh one when it opens.
    readonly property int cellPollMs: 300000

    readonly property string cellReader:
        `${Preferences.configHome}/hypr/scripts/bt-battery`

    readonly property string pairingAgent:
        `${Preferences.configHome}/hypr/scripts/bt-pair-agent`

    property bool pairingMode: false
    property var cellsByAddress: ({})

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

    // A scan turns up far more beacons and privacy addresses
    // than real peripherals, and Quickshell names those after
    // their own address, which is the tell. Listing them buries
    // the one device actually waiting to be paired.
    readonly property var nearby: root.devices
        .filter(device => !root.isPaired(device) && root.named(device))
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

    // One entry per cell rather than per device, so a split
    // keyboard is two things to warn about and not one. Built
    // by hand because the list Quickshell hands back carries
    // only some of the array methods, flatMap not among them.
    readonly property var cellReadings: {
        const found = [];
        for (let index = 0; index < root.linked.length; index++) {
            const device = root.linked[index];
            const cells = root.cellsOf(device);
            for (let cell = 0; cell < cells.length; cell++)
                found.push({
                    address: device.address,
                    name: device.name,
                    label: cells[cell].label,
                    percent: cells[cell].percent
                });
        }
        return found;
    }

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

    function bare(value: string): string {
        return value.replace(/[:-]/g, "").toLowerCase();
    }

    function named(device: var): bool {
        return root.bare(device.name) !== root.bare(device.address);
    }

    function peripheralFor(address: string): var {
        const key = address.toLowerCase();
        return root.peripherals.find(device =>
            device.nativePath.toLowerCase().includes(key)) ?? null;
    }

    function reportedLevel(device: var): real {
        if (device.batteryAvailable) return device.battery;
        const peripheral = root.peripheralFor(device.address);
        if (!peripheral) return root.unknownLevel;
        return peripheral.percentage;
    }

    // A device reporting each cell over GATT is described by
    // those; anything else is the one figure BlueZ or UPower
    // hands over, wrapped as a single unnamed cell so the rest
    // of this file only ever deals in cells.
    function cellsOf(device: var): var {
        const named =
            root.cellsByAddress[device.address.toUpperCase()] ?? [];
        if (named.length > 0) return named;
        const level = root.reportedLevel(device);
        if (level < 0) return [];
        return [{ label: "", percent: Math.round(level * 100) }];
    }

    function levelOf(device: var): real {
        const cells = root.cellsOf(device);
        if (cells.length === 0) return root.unknownLevel;
        return Math.min(...cells.map(cell => cell.percent)) / 100;
    }

    function reports(device: var): bool {
        return root.levelOf(device) >= 0;
    }

    function percentOf(device: var): int {
        return Math.round(root.levelOf(device) * 100);
    }

    function cellText(cell: var): string {
        if (cell.label === "") return `${cell.percent}%`;
        return `${cell.label.charAt(0)} ${cell.percent}%`;
    }

    function batteryLabel(device: var): string {
        return root.cellsOf(device)
            .map(cell => root.cellText(cell))
            .join(" · ");
    }

    function absorbCells(payload: string): void {
        try {
            const seen = JSON.parse(payload);
            const next = ({});
            for (const device of seen.devices ?? [])
                next[device.address.toUpperCase()] = device.cells;
            root.cellsByAddress = next;
        } catch (error) {
            root.cellsByAddress = ({});
        }
    }

    function readCells(): void {
        if (!root.powered) return;
        cellReaderProcess.running = true;
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

    readonly property bool discoveryWanted:
        root.pairingMode && root.powered

    // Two things have to be true before a device can be paired.
    // Discovery is what makes one visible at all, and BlueZ
    // refuses to finish a pairing with no agent to answer for
    // the passkey, failing with nothing shown to the person who
    // pressed the button. Both cost something while they run,
    // so the pane holds them open only while it is shown.
    function setPairingMode(wanted: bool): void {
        root.pairingMode = wanted;
    }

    // Held as an intention and applied whenever the adapter can
    // take it, since it is not there for the first seconds of a
    // session and can be switched off underneath an open pane.
    function applyPairingMode(): void {
        if (!root.adapter) return;
        root.adapter.discovering = root.discoveryWanted;
    }

    onDiscoveryWantedChanged: root.applyPairingMode()
    onAdapterChanged: root.applyPairingMode()

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

    onLinkedCountChanged: root.readCells()

    Process {
        id: cellReaderProcess

        command: [root.cellReader]

        stdout: StdioCollector {
            onStreamFinished: root.absorbCells(this.text)
        }
    }

    Process {
        running: root.discoveryWanted
        command: [root.pairingAgent]
    }

    Timer {
        running: root.powered
        interval: root.cellPollMs
        repeat: true
        triggeredOnStart: true

        onTriggered: root.readCells()
    }
}
