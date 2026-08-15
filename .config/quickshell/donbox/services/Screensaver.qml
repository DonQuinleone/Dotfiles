pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property int tintCount: 3
    readonly property real groundDarkening: 1.4
    readonly property real groundLuminanceCeiling: 0.1
    readonly property real glowCeiling: 0.35
    readonly property real driftRateAcross: 0.0121
    readonly property real driftRateDown: 0.0087
    readonly property real driftTravel: 0.38

    readonly property var groundCandidates:
        ["bg", "bgAlt", "surface", "fg", "fgDim", "border"]

    readonly property var saverNames: ["lava", "windmill", "rain"]
    readonly property var modeNames: ["cycle", "off"]

    readonly property string glyphAlphabet:
        "0123456789ABCDEF#$%&*+=<>/|[]{}!?~^"

    property bool active: false
    property real elapsed: 0
    property string saver: root.saverNames[0]

    readonly property string choice:
        Preferences.value("screensaver")

    readonly property real glow: Math.min(root.glowCeiling,
        Theme.opacities.dim ?? root.glowCeiling)

    // Light themes have no dark background to lend, so the
    // darkest colour they do carry is taken down to a level an
    // OLED can hold for hours.
    readonly property color ground: {
        let darkest = Theme.palette.bg ?? "black";
        for (const name of root.groundCandidates) {
            const shade = Theme.palette[name];
            if (!shade) continue;
            if (Theme.luminance(shade) >= Theme.luminance(darkest))
                continue;
            darkest = shade;
        }
        const factor = Math.max(root.groundDarkening,
            Theme.luminance(darkest) / root.groundLuminanceCeiling);
        return Qt.darker(darkest, factor);
    }

    readonly property var tints: {
        const pool = Object.values(Theme.accents ?? ({}));
        const spares = [Theme.palette.accent, Theme.palette.accentSoft,
            Theme.palette.warn].filter(shade => !!shade);
        const chosen = pool.length > 0 ? pool : spares;
        const picked = [];
        for (let index = 0; index < root.tintCount; index++)
            picked.push(chosen[index % chosen.length] ?? "white");
        return picked;
    }

    function choose(): string {
        if (root.saverNames.includes(root.choice)) return root.choice;
        return root.saverNames[
            Math.floor(Math.random() * root.saverNames.length)];
    }

    function select(name: string): string {
        const known = root.saverNames.concat(root.modeNames);
        if (!known.includes(name))
            return `no screensaver '${name}'; ` +
                `one of: ${known.join(" ")}`;
        Preferences.set("screensaver", name);
        return name;
    }

    function names(): string {
        const marker = name =>
            name === root.choice ? `* ${name}` : `  ${name}`;
        return root.saverNames.concat(root.modeNames)
            .map(marker).join("\n");
    }

    function start(): void {
        if (Lock.locked) return;
        if (root.choice === "off") return;
        root.saver = root.choose();
        root.active = true;
    }

    function stop(): void {
        root.active = false;
    }

    Connections {
        target: Lock

        function onLockedChanged(): void {
            if (Lock.locked) root.stop();
        }
    }

    FrameAnimation {
        running: root.active

        onTriggered: root.elapsed += this.frameTime
    }
}
