import QtQuick
import qs.services

Item {
    id: root

    // Kept to glyphs a programming font certainly carries, so no
    // column ever falls back to a proportional face and breaks
    // the grid.
    readonly property string glyphs:
        "0123456789ABCDEF#$%&*+=<>/|[]{}!?~^"

    readonly property int trailLength: 14
    readonly property int maximumColumns: 48
    readonly property int churnMs: 130
    readonly property int fallMsFloor: 6000
    readonly property int fallMsSpread: 7000
    readonly property real trailOpacity: 0.55

    property color tint: Theme.palette.accent ?? "white"
    property color headTint: Theme.palette.fg ?? "white"

    readonly property bool falling: !Theme.reduceMotion

    readonly property int columnCount: Math.max(1, Math.min(
        root.maximumColumns,
        Math.floor(root.width / LockMetrics.rainSpacing)))

    readonly property real columnSpacing: root.width / root.columnCount

    readonly property int trailHeight:
        LockMetrics.traceLine * root.trailLength

    clip: true

    function glyph(): string {
        return root.glyphs.charAt(
            Math.floor(Math.random() * root.glyphs.length));
    }

    function strand(): string {
        const cells = [];
        for (let step = 0; step < root.trailLength; step++) {
            cells.push(root.glyph());
        }
        return cells.join("\n");
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
                lineHeight: LockMetrics.traceLine
                lineHeightMode: Text.FixedHeight
                font.family: Theme.fonts.mono ?? ""
                font.pixelSize: LockMetrics.traceSize
            }

            Text {
                id: head

                y: LockMetrics.traceLine * (root.trailLength - 1)
                text: root.glyph()
                color: root.headTint
                font.family: Theme.fonts.mono ?? ""
                font.pixelSize: LockMetrics.traceSize
            }
        }
    }

    Timer {
        running: root.falling
        interval: root.churnMs
        repeat: true

        onTriggered: {
            const target = columns.itemAt(
                Math.floor(Math.random() * root.columnCount));
            if (target) target.refresh();
        }
    }
}
