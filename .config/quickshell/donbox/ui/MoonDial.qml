import QtQuick
import qs.services

// The moon as it actually looks tonight: a lit disc cut by the
// terminator, which is a half ellipse whose width follows the
// phase, flattening to a straight edge at the quarters and
// bulging the other way as the moon fills. South of the equator
// the whole thing is seen upside down, so the lit side swaps.
Canvas {
    id: root

    property real phase: Moon.phase
    property bool mirrored:
        (Location.place?.latitude ?? 0) < 0

    property color lit: Theme.palette.fg ?? "white"
    property color unlit: Theme.palette.bg ?? "black"
    property color rim: Theme.palette.border ?? "transparent"

    readonly property int samples: 72
    readonly property int rimWidth: 1

    implicitWidth: (Theme.sizes.iconNormal ?? 0) * 2
    implicitHeight: root.implicitWidth
    antialiasing: true

    onPhaseChanged: root.requestPaint()
    onLitChanged: root.requestPaint()
    onUnlitChanged: root.requestPaint()
    onMirroredChanged: root.requestPaint()

    onPaint: {
        const ctx = root.getContext("2d");
        const middle = Math.min(root.width, root.height) / 2;
        const radius = middle - root.rimWidth;
        const angle = 2 * Math.PI * root.phase;
        const waxing = root.phase < Moon.fullPhase;
        const side = waxing !== root.mirrored ? 1 : -1;
        const squeeze = Math.cos(angle);

        ctx.reset();

        ctx.beginPath();
        ctx.arc(middle, middle, radius, 0, 2 * Math.PI);
        ctx.fillStyle = root.unlit;
        ctx.fill();
        ctx.lineWidth = root.rimWidth;
        ctx.strokeStyle = root.rim;
        ctx.stroke();

        ctx.beginPath();
        for (let step = 0; step <= root.samples; step++) {
            const along = Math.PI * step / root.samples;
            ctx.lineTo(middle + side * radius * Math.sin(along),
                middle - radius * Math.cos(along));
        }
        for (let step = root.samples; step >= 0; step--) {
            const along = Math.PI * step / root.samples;
            ctx.lineTo(
                middle + side * radius * squeeze * Math.sin(along),
                middle - radius * Math.cos(along));
        }
        ctx.closePath();
        ctx.fillStyle = root.lit;
        ctx.fill();
    }
}
