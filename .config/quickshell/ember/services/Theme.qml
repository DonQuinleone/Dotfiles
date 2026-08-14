pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string activeTheme: "current"
    readonly property string fallbackTheme: "ember"

    property bool usingFallback: false

    readonly property string configHome:
        Quickshell.env("XDG_CONFIG_HOME")
        ?? `${Quickshell.env("HOME")}/.config`

    readonly property string themeName: root.usingFallback
        ? root.fallbackTheme
        : root.activeTheme

    readonly property string path:
        `${root.configHome}/quickshell/themes/${root.themeName}.json`

    property var data: ({})

    readonly property var palette: root.data.palette ?? ({})
    readonly property var fonts: root.data.fonts ?? ({})
    readonly property var fontSizes: root.data.fontSizes ?? ({})
    readonly property var fontWeights: root.data.fontWeights ?? ({})
    readonly property var radii: root.data.radii ?? ({})
    readonly property var spacing: root.data.spacing ?? ({})
    readonly property var sizes: root.data.sizes ?? ({})
    readonly property var opacities: root.data.opacities ?? ({})
    readonly property var accents: root.data.accents ?? ({})

    readonly property var animation: root.data.animation ?? ({})
    readonly property var durations: root.animation.durations ?? ({})
    readonly property var easings: root.animation.easings ?? ({})

    readonly property bool reduceMotion: root.data.reduceMotion ?? false

    readonly property real lumaRedWeight: 0.299
    readonly property real lumaGreenWeight: 0.587
    readonly property real lumaBlueWeight: 0.114

    readonly property color onAccent:
        root.readableOn(root.palette.accent ?? "black")

    readonly property url wallpaper: root.data.wallpaper
        ? `file://${root.expandHome(root.data.wallpaper)}`
        : ""

    readonly property var easingCurves: ({
        "Linear": Easing.Linear,
        "InQuad": Easing.InQuad,
        "OutQuad": Easing.OutQuad,
        "InOutQuad": Easing.InOutQuad,
        "OutCubic": Easing.OutCubic,
        "InOutCubic": Easing.InOutCubic,
        "OutQuart": Easing.OutQuart,
        "OutQuint": Easing.OutQuint,
        "OutExpo": Easing.OutExpo,
        "OutBack": Easing.OutBack
    })

    function duration(role: string): int {
        if (root.reduceMotion) return 0;
        return root.durations[role] ?? 0;
    }

    function easing(role: string): int {
        return root.easingCurves[root.easings[role]] ?? Easing.Linear;
    }

    function luminance(shade: color): real {
        return shade.r * root.lumaRedWeight
            + shade.g * root.lumaGreenWeight
            + shade.b * root.lumaBlueWeight;
    }

    function readableOn(shade: color): color {
        const background = root.palette.bg ?? "black";
        const foreground = root.palette.fg ?? "white";
        const subject = root.luminance(shade);
        const toBackground =
            Math.abs(subject - root.luminance(background));
        const toForeground =
            Math.abs(subject - root.luminance(foreground));
        return toBackground >= toForeground ? background : foreground;
    }

    function applyAccent(name: string): void {
        accentSwitch.command = [
            `${root.configHome}/hypr/scripts/theme`, "accent", name];
        accentSwitch.running = true;
    }

    function expandHome(target: string): string {
        if (!target.startsWith("~/")) return target;
        return `${Quickshell.env("HOME")}${target.substring(1)}`;
    }

    function reparse(): void {
        try {
            root.data = JSON.parse(file.text());
        } catch (error) {
            console.error(
                `ember: ${root.path} is not valid JSON:`, error);
        }
    }

    Component.onCompleted: root.reparse()

    Process {
        id: accentSwitch
    }

    FileView {
        id: file

        path: root.path
        watchChanges: true
        blockLoading: true

        onFileChanged: this.reload()
        onLoaded: root.reparse()
        onLoadFailed: error => {
            if (!root.usingFallback) {
                root.usingFallback = true;
                return;
            }
            console.error(
                `ember: cannot read ${root.path}:`,
                FileViewError.toString(error));
        }
    }
}
