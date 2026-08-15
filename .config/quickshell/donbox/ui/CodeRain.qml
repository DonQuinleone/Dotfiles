import QtQuick
import qs.services

// The same register as the locker's rain, kept sparser and
// dimmer because this surface may hold an OLED for hours.
Item {
    id: root

    readonly property int trailLength: 16
    readonly property int maximumColumns: 36
    readonly property int churnMs: 150
    readonly property int fallMsFloor: 9000
    readonly property int fallMsSpread: 9000
    readonly property real trailOpacity: 0.4
    readonly property real headOpacity: 0.75
    readonly property real glyphScale: 1.2
    readonly property real lineTightness: 1.35
    readonly property real spacingInGlyphs: 2.6

    readonly property int glyphSize: Math.round(
        (Theme.fontSizes.display ?? 25) * root.glyphScale)
    readonly property int lineStep: Math.round(
        root.glyphSize * root.lineTightness)
    readonly property int columnSpan: Math.round(
        root.glyphSize * root.spacingInGlyphs)

    property color tint: Theme.palette.accent ?? "white"
    property color headTint: Theme.palette.fg ?? "white"

    readonly property bool falling: !Theme.reduceMotion

    readonly property int columnCount: Math.max(1, Math.min(
        root.maximumColumns,
        Math.floor(root.width / root.columnSpan)))

    readonly property real columnSpacing: root.width / root.columnCount

    readonly property int trailHeight:
        root.lineStep * root.trailLength

    clip: true

    function glyph(): string {
        return Screensaver.glyphAlphabet.charAt(Math.floor(
            Math.random() * Screensaver.glyphAlphabet.length));
    }

    function strand(): string {
        const cells = [];
        for (let step = 0; step < root.trailLength; step++) {
            cells.push(root.glyph());
        }
        return cells.join("\n");
    }

    Rectangle {
        anchors.fill: parent
        color: Screensaver.ground
    }

    Repeater {
        id: columns

        model: root.columnCount

        Item {
            id: column

            required property int index

            readonly property int fallMs: root.fallMsFloor
                + Math.round(Math.random() * root.fallMsSpread)
            readonly property int delayMs:
                Math.round(Math.random() * root.fallMsFloor)
            readonly property int restY:
                Math.round(Math.random() * root.height)

            function refresh(): void {
                trail.text = root.strand();
                head.text = root.glyph();
            }

            x: Math.round(column.index * root.columnSpacing)
            width: root.columnSpacing
            height: root.trailHeight

            Component.onCompleted: column.y = root.falling
                ? -column.height
                : column.restY

            SequentialAnimation on y {
                running: root.falling
                loops: Animation.Infinite

                PauseAnimation {
                    duration: column.delayMs
                }

                NumberAnimation {
                    from: -column.height
                    to: root.height
                    duration: column.fallMs
                }
            }

            Text {
                id: trail

                text: root.strand()
                color: root.tint
                opacity: root.trailOpacity
                lineHeight: root.lineStep
                lineHeightMode: Text.FixedHeight
                font.family: Theme.fonts.mono ?? ""
                font.pixelSize: root.glyphSize
            }

            Text {
                id: head

                y: root.lineStep * (root.trailLength - 1)
                text: root.glyph()
                color: root.headTint
                opacity: root.headOpacity
                font.family: Theme.fonts.mono ?? ""
                font.pixelSize: root.glyphSize
            }
        }
    }

    Timer {
        running: root.falling && root.visible
        interval: root.churnMs
        repeat: true

        onTriggered: {
            const target = columns.itemAt(
                Math.floor(Math.random() * root.columnCount));
            if (target) target.refresh();
        }
    }
}
