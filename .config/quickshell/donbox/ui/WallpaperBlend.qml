import QtQuick
import Quickshell
import qs.services

ShaderEffect {
    id: root

    required property Image outgoing
    required property Image incoming

    readonly property string tempoRole: "slow"

    property real progress: 1
    property real kind: 0
    property real angle: 0
    property real originX: 0.5
    property real originY: 0.5
    property real grain: 0

    readonly property real aspect:
        root.width / Math.max(1, root.height)

    readonly property real outgoingCover: root.coverage(root.outgoing)
    readonly property real incomingCover: root.coverage(root.incoming)

    blending: false

    fragmentShader:
        `file://${Quickshell.shellPath("shaders/wallpaper.frag.qsb")}`

    function coverage(picture: Image): real {
        const wide = Math.max(1, picture.implicitWidth);
        const tall = Math.max(1, picture.implicitHeight);
        return root.aspect / (wide / tall);
    }

    function play(transition: var): void {
        root.kind = transition.kind;
        root.angle = transition.angle;
        root.originX = transition.origin.x;
        root.originY = transition.origin.y;
        root.grain = transition.grain;
        sweep.duration =
            Theme.duration(root.tempoRole) * transition.beats;
        sweep.easing.type = Theme.easing(transition.curve);
        root.progress = 0;
        sweep.restart();
    }

    function settle(): void {
        sweep.stop();
        root.progress = 1;
    }

    // Swapping the slots hands the incoming role to a picture
    // that is still loading, and the shader would spend those
    // frames drawing an empty texture.
    function hold(): void {
        sweep.stop();
        root.progress = 0;
    }

    NumberAnimation {
        id: sweep

        target: root
        property: "progress"
        to: 1
    }
}
