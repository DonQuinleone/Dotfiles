import QtQuick
import Quickshell

Scope {
    id: root

    readonly property string appName: "Bluetooth"
    readonly property int settleMs: 1500

    readonly property int lowWarningPercent: 20
    readonly property int criticalWarningPercent: 5

    readonly property var warnings: [
        {
            floor: root.criticalWarningPercent,
            urgency: "critical",
            body: qsTr("Charge it now.")
        },
        {
            floor: root.lowWarningPercent,
            urgency: "normal",
            body: qsTr("Charge it soon.")
        }
    ]

    property bool settled: false
    property var armed: ({})

    // A split keyboard reports a cell per half, so the key has
    // to carry the side as well as the device; without it the
    // second half would inherit the first one's silence.
    function keyFor(reading: var, floor: int): string {
        return `${reading.address}|${reading.label}|${floor}`;
    }

    function armedFor(key: string): bool {
        return root.armed[key] !== false;
    }

    function titleFor(reading: var): string {
        if (reading.label === "") return reading.name;
        return `${reading.name} (${reading.label})`;
    }

    function due(reading: var, rule: var): bool {
        return reading.percent <= rule.floor
            && root.armedFor(root.keyFor(reading, rule.floor));
    }

    function warn(reading: var, rule: var): void {
        Quickshell.execDetached(["notify-send",
            "--app-name", root.appName,
            "--urgency", rule.urgency,
            qsTr("%1 battery low: %2%")
                .arg(root.titleFor(reading))
                .arg(reading.percent),
            rule.body]);
    }

    // Rules run severest first, so a cell found below both lines
    // is announced once, and both lines it passed stay quiet
    // until it charges back over them.
    function reviewReading(reading: var, next: var): void {
        const fired = root.warnings.filter(rule =>
            root.due(reading, rule));
        if (fired.length > 0) root.warn(reading, fired[0]);
        for (const rule of root.warnings) {
            const key = root.keyFor(reading, rule.floor);
            next[key] = reading.percent > rule.floor
                || (root.armedFor(key) && fired.indexOf(rule) < 0);
        }
    }

    // Carried over rather than rebuilt, or a device that drops
    // off and comes back still flat would be announced again on
    // every reconnection.
    function review(): void {
        if (!root.settled) return;
        const next = Object.assign({}, root.armed);
        for (const reading of BluetoothRadio.cellReadings)
            root.reviewReading(reading, next);
        root.armed = next;
    }

    Connections {
        target: BluetoothRadio

        function onCellReadingsChanged(): void {
            root.review();
        }
    }

    Timer {
        running: true
        interval: root.settleMs

        onTriggered: {
            root.settled = true;
            root.review();
        }
    }
}
