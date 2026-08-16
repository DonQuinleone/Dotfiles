import QtQuick
import Quickshell

Scope {
    id: root

    readonly property string appName: "Battery"
    readonly property int settleMs: 700

    readonly property int lowWarningPercent: 20
    readonly property int criticalWarningPercent: 10

    readonly property var warnings: [
        {
            floor: root.criticalWarningPercent,
            urgency: "critical",
            summary: qsTr("Battery critically low: %1%"),
            body: qsTr("Plug in the charger now.")
        },
        {
            floor: root.lowWarningPercent,
            urgency: "normal",
            summary: qsTr("Battery low: %1%"),
            body: qsTr("Plug in the charger soon.")
        }
    ]

    // UPower answers nothing until its first poll, and an
    // unanswered reading is indistinguishable from a flat cell.
    readonly property bool percentKnown: Battery.percent > 0

    property bool settled: false
    property var armed: ({})

    function armedFor(floor: int): bool {
        return root.armed[floor] !== false;
    }

    function due(rule: var): bool {
        return Battery.percent <= rule.floor
            && !Battery.charging
            && root.armedFor(rule.floor);
    }

    function rearmed(rule: var, fired: var): bool {
        if (Battery.percent > rule.floor) return true;
        return root.armedFor(rule.floor) && fired.indexOf(rule) < 0;
    }

    function warn(rule: var): void {
        Quickshell.execDetached(["notify-send",
            "--app-name", root.appName,
            "--urgency", rule.urgency,
            rule.summary.arg(Battery.percent),
            rule.body]);
    }

    // The rules run severest first, so one steep drop past both
    // lines announces the worse of them alone, and every line it
    // crossed stays quiet until the charge climbs back over it.
    function review(): void {
        if (!root.settled || !root.percentKnown) return;
        const rules = root.warnings;
        const fired = rules.filter(rule => root.due(rule));
        if (fired.length > 0) root.warn(fired[0]);
        const next = ({});
        for (const rule of rules)
            next[rule.floor] = root.rearmed(rule, fired);
        root.armed = next;
    }

    Connections {
        target: Battery

        function onPercentChanged(): void {
            root.review();
        }

        function onChargingChanged(): void {
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
