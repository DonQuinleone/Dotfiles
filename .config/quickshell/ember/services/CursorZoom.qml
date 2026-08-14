pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property int pollIntervalMs: 500
    readonly property real neutralFactor: 1.0
    readonly property real maximumFactor: 8.0
    readonly property real step: 1.0

    property real factor: root.neutralFactor

    readonly property bool magnified: root.factor > root.neutralFactor
    readonly property int percent: Math.round(root.factor * 100)

    // The Lua config parser rejects `hyprctl keyword`, so writes
    // go through the same `hl.config` call the keybinds use.
    // Adopting the value locally keeps the controls responsive
    // between polls; the next poll confirms it.
    function set(value: real): void {
        const wanted = Math.max(root.neutralFactor,
            Math.min(root.maximumFactor, value));
        Quickshell.execDetached(["hyprctl", "eval",
            `hl.config({ cursor = { zoom_factor = ${wanted} } })`]);
        root.factor = wanted;
    }

    function nudge(delta: real): void {
        root.set(root.factor + delta);
    }

    function reset(): void {
        root.set(root.neutralFactor);
    }

    function apply(payload: string): void {
        try {
            root.factor =
                JSON.parse(payload).float ?? root.neutralFactor;
        } catch (error) {
            root.factor = root.neutralFactor;
        }
    }

    Process {
        id: probe

        command: ["hyprctl", "-j", "getoption", "cursor:zoom_factor"]

        stdout: StdioCollector {
            onStreamFinished: root.apply(this.text)
        }
    }

    Timer {
        running: true
        repeat: true
        triggeredOnStart: true
        interval: root.pollIntervalMs

        onTriggered: if (!probe.running) probe.running = true
    }
}
