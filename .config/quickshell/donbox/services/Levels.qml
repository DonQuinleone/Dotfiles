pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property real step: 0.05
    readonly property int percentScale: 100

    readonly property var volumeWords: [
        { floor: 0.85, word: "LOUD" },
        { floor: 0.55, word: "MODERATE" },
        { floor: 0.25, word: "QUIET" },
        { floor: 0.01, word: "FAINT" },
        { floor: 0.0, word: "SILENT" }
    ]

    readonly property var brightnessWords: [
        { floor: 0.85, word: "BRIGHT" },
        { floor: 0.55, word: "NORMAL" },
        { floor: 0.25, word: "DIM" },
        { floor: 0.0, word: "DARK" }
    ]

    function wordFor(scale: var, level: real): string {
        return scale.find(band => level >= band.floor).word;
    }

    function percent(level: real): string {
        return `${Math.round(level * root.percentScale)}%`;
    }

    function readout(scale: var, level: real): string {
        return `${root.percent(level)} · `
            + root.wordFor(scale, level);
    }
}
