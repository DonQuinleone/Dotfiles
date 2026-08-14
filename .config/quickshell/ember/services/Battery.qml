pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property int lowPercent: 25
    readonly property int criticalPercent: 10

    readonly property string chargingGlyph: "󰂄"

    readonly property var levels: [
        { floor: 90, glyph: "󰁹" },
        { floor: 70, glyph: "󰂀" },
        { floor: 50, glyph: "󰁾" },
        { floor: 30, glyph: "󰁼" },
        { floor: 10, glyph: "󰁺" },
        { floor: 0, glyph: "󰂃" }
    ]

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
}
