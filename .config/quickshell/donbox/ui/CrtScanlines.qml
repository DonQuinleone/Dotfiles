import QtQuick
import Quickshell
import qs.services

// The shader takes no clock, so the overlay cannot flicker on a
// panel that would rather not be strobed at.
ShaderEffect {
    id: root

    readonly property int linePitchPx: 4
    readonly property real scanWeight: 0.14
    readonly property real vignetteWeight: 0.55
    readonly property real vignetteSpread: 0.45

    readonly property color tint: Theme.palette.bg ?? "black"
    readonly property real scanPitch: root.height / root.linePitchPx

    fragmentShader:
        `file://${Quickshell.shellPath("shaders/crt.frag.qsb")}`
}
