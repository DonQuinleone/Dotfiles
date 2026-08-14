import QtQuick
import Quickshell.Services.UPower
import qs.services

BarPill {
    id: root

    readonly property int lowPercent: 25
    readonly property int criticalPercent: 10

    readonly property var levels: [
        { floor: 90, glyph: "󰁹" },
        { floor: 70, glyph: "󰂀" },
        { floor: 50, glyph: "󰁾" },
        { floor: 30, glyph: "󰁼" },
        { floor: 10, glyph: "󰁺" },
        { floor: 0, glyph: "󰂃" }
    ]

    readonly property var device: UPower.displayDevice
    readonly property bool charging:
        root.device.state === UPowerDeviceState.Charging
        || root.device.state === UPowerDeviceState.FullyCharged
    readonly property int percent:
        Math.round(root.device.percentage * 100)

    readonly property string glyph: {
        if (root.charging) return "󰂄";
        return root.levels
            .find(level => root.percent >= level.floor).glyph;
    }

    readonly property color tint: {
        if (root.charging) return Theme.palette.good;
        if (root.percent <= root.criticalPercent)
            return Theme.palette.bad;
        if (root.percent <= root.lowPercent)
            return Theme.palette.warn;
        return Theme.palette.fg;
    }

    visible: root.device.ready && root.device.isLaptopBattery

    content: [
        PillText {
            text: root.glyph
            color: root.tint
            font.pixelSize: Theme.sizes.iconNormal ?? 0
        },
        PillText {
            text: `${root.percent}%`
            color: root.tint
        }
    ]
}
