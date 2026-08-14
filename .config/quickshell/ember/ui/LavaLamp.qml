import QtQuick
import Quickshell
import qs.services

ShaderEffect {
    id: root

    readonly property real time: Screensaver.elapsed
    readonly property real aspect: root.width / Math.max(1, root.height)
    readonly property real glow: Screensaver.glow
    readonly property color ground: Screensaver.ground
    readonly property color tintA: Screensaver.tints[0]
    readonly property color tintB: Screensaver.tints[1]
    readonly property color tintC: Screensaver.tints[2]

    fragmentShader:
        `file://${Quickshell.shellPath("shaders/lavalamp.frag.qsb")}`
}
