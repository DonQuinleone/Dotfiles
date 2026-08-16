pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower

Singleton {
    id: root

    readonly property int lowPercent: 25
    readonly property int criticalPercent: 10

    readonly property string chargingGlyph: "󰂄"

    readonly property real microUnitsPerUnit: 1000000
    readonly property int secondsPerMinute: 60
    readonly property int minutesPerHour: 60
    readonly property int wholePercent: 100
    readonly property int chargeDecimals: 1

    readonly property string supplyRoot: "/sys/class/power_supply"
    readonly property string cycleCountName: "cycle_count"

    readonly property var levels: [
        { floor: 90, glyph: "󰁹" },
        { floor: 70, glyph: "󰂀" },
        { floor: 50, glyph: "󰁾" },
        { floor: 30, glyph: "󰁼" },
        { floor: 10, glyph: "󰁺" },
        { floor: 0, glyph: "󰂃" }
    ]

    readonly property var capacityFamilies: [
        {
            full: "energy_full",
            design: "energy_full_design",
            unit: qsTr("Wh")
        },
        {
            full: "charge_full",
            design: "charge_full_design",
            unit: qsTr("Ah")
        }
    ]

    readonly property var stateWords: [
        {
            state: UPowerDeviceState.Charging,
            words: qsTr("Charging")
        },
        {
            state: UPowerDeviceState.Discharging,
            words: qsTr("On battery")
        },
        {
            state: UPowerDeviceState.FullyCharged,
            words: qsTr("Fully charged")
        },
        {
            state: UPowerDeviceState.Empty,
            words: qsTr("Empty")
        },
        {
            state: UPowerDeviceState.PendingCharge,
            words: qsTr("Waiting to charge")
        },
        {
            state: UPowerDeviceState.PendingDischarge,
            words: qsTr("Waiting to discharge")
        },
        {
            state: UPowerDeviceState.Unknown,
            words: qsTr("State unknown")
        }
    ]

    readonly property var sysfsNames: root.capacityFamilies.reduce(
        (names, family) => names.concat([family.full, family.design]),
        [root.cycleCountName])

    property var sysfs: ({})

    readonly property var device: UPower.displayDevice

    readonly property var cell: (UPower.devices?.values ?? [])
        .find(candidate => candidate.isLaptopBattery)

    readonly property string supplyDirectory: root.cell?.nativePath
        ? `${root.supplyRoot}/${root.cell.nativePath}`
        : ""

    readonly property var family: root.capacityFamilies.find(
        candidate => root.sysfs[candidate.full] > 0
            && root.sysfs[candidate.design] > 0)

    readonly property bool capacityKnown: root.family !== undefined

    readonly property real fullCharge: root.capacityKnown
        ? root.sysfs[root.family.full] / root.microUnitsPerUnit
        : 0

    readonly property real designCharge: root.capacityKnown
        ? root.sysfs[root.family.design] / root.microUnitsPerUnit
        : 0

    readonly property string fullChargeWords: root.capacityKnown
        ? qsTr("%1 of %2 %3")
            .arg(root.fullCharge.toFixed(root.chargeDecimals))
            .arg(root.designCharge.toFixed(root.chargeDecimals))
            .arg(root.family.unit)
        : ""

    readonly property bool healthKnown: root.capacityKnown
        || (root.cell?.healthSupported ?? false)

    readonly property int healthPercent: root.capacityKnown
        ? Math.round(
            root.fullCharge / root.designCharge * root.wholePercent)
        : Math.round(root.cell?.healthPercentage ?? 0)

    readonly property bool cycleCountKnown:
        root.sysfs[root.cycleCountName] !== undefined

    readonly property int cycleCount:
        root.sysfs[root.cycleCountName] ?? 0

    readonly property int chargeState:
        root.device?.state ?? UPowerDeviceState.Unknown

    readonly property bool charging:
        root.chargeState === UPowerDeviceState.Charging
        || root.chargeState === UPowerDeviceState.FullyCharged

    readonly property bool pluggedIn: !UPower.onBattery

    readonly property int percent:
        Math.round((root.device?.percentage ?? 0) * root.wholePercent)

    readonly property real secondsToEmpty: root.device?.timeToEmpty ?? 0
    readonly property real secondsToFull: root.device?.timeToFull ?? 0

    function glyphFor(percent: int): string {
        const level = Math.max(0, percent);
        return root.levels.find(step => level >= step.floor).glyph;
    }

    function low(percent: int): bool {
        return percent <= root.lowPercent;
    }

    function tintFor(percent: int): color {
        if (percent <= root.criticalPercent)
            return Theme.palette.bad ?? "white";
        if (percent <= root.lowPercent)
            return Theme.palette.warn ?? "white";
        return Theme.palette.fg ?? "white";
    }

    function wordsForState(state: int): string {
        const known = root.stateWords.find(
            entry => entry.state === state);
        return known ? known.words : "";
    }

    function counted(amount: int, one: string, many: string): string {
        return `${amount} ${amount === 1 ? one : many}`;
    }

    function spellDuration(seconds: real): string {
        const total = Math.round(seconds / root.secondsPerMinute);
        const hours = Math.floor(total / root.minutesPerHour);
        const minutes = total % root.minutesPerHour;
        const spelt = [];
        if (hours > 0)
            spelt.push(
                root.counted(hours, qsTr("hour"), qsTr("hours")));
        if (minutes > 0 || hours === 0)
            spelt.push(
                root.counted(minutes, qsTr("minute"), qsTr("minutes")));
        return spelt.join(qsTr(" and "));
    }

    function readText(path: string): string {
        const view = reader.createObject(root, { path: path });
        const contents = view.text();
        view.destroy();
        return contents;
    }

    function refresh(): void {
        if (root.supplyDirectory === "") return;
        const readings = ({});
        root.sysfsNames.forEach(name => {
            const raw = root.readText(
                `${root.supplyDirectory}/${name}`).trim();
            if (raw !== "") readings[name] = Number(raw);
        });
        root.sysfs = readings;
    }

    onSupplyDirectoryChanged: root.refresh()

    Component.onCompleted: root.refresh()

    Component {
        id: reader

        FileView {
            blockLoading: true
            printErrors: false
        }
    }
}
