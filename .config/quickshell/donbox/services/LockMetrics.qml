pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property real clockScale: 3.2
    readonly property real headingScale: 1.2
    readonly property real entryScale: 1.0
    readonly property real traceScale: 0.8

    readonly property int terminalColumns: 46
    readonly property real rainAdvances: 3
    readonly property real sweepShare: 0.28
    readonly property int maximumBullets: 32

    readonly property int base: Theme.fontSizes.display ?? 0

    readonly property int clockSize:
        Math.round(root.base * root.clockScale)
    readonly property int headingSize:
        Math.round(root.base * root.headingScale)
    readonly property int entrySize:
        Math.round(root.base * root.entryScale)
    readonly property int traceSize:
        Math.round(root.base * root.traceScale)

    readonly property string ruleGlyph: "─"
    readonly property string fingerprintGlyph: "󰈷"
    readonly property string mediaGlyph: "󰎈"

    readonly property real traceCell: traceMetrics.advanceWidth("0")
    readonly property int traceLine: Math.round(traceMetrics.height)
    readonly property real entryCell: entryMetrics.advanceWidth("0")
    readonly property int entryLine: Math.round(entryMetrics.height)

    readonly property int terminalWidth:
        Math.round(root.traceCell * root.terminalColumns)

    // Box drawing is not always laid out on the same advance as
    // the digits, so the rule counts its own glyph.
    readonly property string rule: root.ruleGlyph.repeat(
        Math.max(1, Math.floor(root.terminalWidth
            / traceMetrics.advanceWidth(root.ruleGlyph))))

    readonly property int caretWidth:
        Math.max(1, Math.round(root.entryCell))

    readonly property int rainSpacing:
        Math.max(1, Math.round(root.traceCell * root.rainAdvances))

    FontMetrics {
        id: traceMetrics

        font.family: Theme.fonts.mono ?? ""
        font.pixelSize: root.traceSize
    }

    FontMetrics {
        id: entryMetrics

        font.family: Theme.fonts.mono ?? ""
        font.pixelSize: root.entrySize
    }
}
