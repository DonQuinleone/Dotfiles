import QtQuick
import Quickshell.Io
import qs.services

// The donbox mark turning under the stars, with the decrypt-style
// dissolve Omarchy's terminal screensaver made famous, rebuilt
// natively so it can follow the palette and stay OLED-gentle: the
// scramble only ever swaps glyphs inside the mark's silhouette,
// so brightness never jumps.
Item {
    id: root

    readonly property int frameCount: 8
    readonly property int frameLines: 17
    readonly property int turnMs: 700
    readonly property int holdMs: 45000
    readonly property int meltMs: 6000
    readonly property int meltedMs: 2500
    readonly property int churnMs: 180
    readonly property int minimumGlyphPx: 12
    readonly property real driftTravel: 0.05
    readonly property real artHeightShare: 0.55
    // Terminal cells stack at exactly one glyph height; anything
    // looser breaks the blade diagonals into dashes.
    readonly property real lineTightness: 1.0
    readonly property real artOpacity: 0.85

    readonly property var blockRows: [
        { from: 0, to: 8, role: "accent" },
        { from: 9, to: 12, role: "fg" },
        { from: 13, to: 14, role: "fgDim" },
        { from: 15, to: 16, role: "accent" }
    ]

    readonly property string logoDir:
        `${Theme.configHome}/fastfetch/logo`

    property var frames: []
    property int frame: 0
    property real chaos: 0
    property var mask: ({})

    readonly property bool turning: !Theme.reduceMotion

    readonly property int glyphSize: Math.max(root.minimumGlyphPx,
        Math.floor(root.height * root.artHeightShare
            / root.frameLines / root.lineTightness))

    readonly property int lineStep: Math.round(
        root.glyphSize * root.lineTightness)

    readonly property real across: !root.turning ? 0.5
        : 0.5 + root.driftTravel * Math.cos(
            Screensaver.elapsed * Screensaver.driftRateAcross)

    readonly property real down: !root.turning ? 0.5
        : 0.5 + root.driftTravel * Math.sin(
            Screensaver.elapsed * Screensaver.driftRateDown)

    function framePaths(): var {
        const paths = [];
        for (let number = 1; number <= root.frameCount; number++) {
            const stamp = String(number).padStart(2, "0");
            paths.push(`${root.logoDir}/frames/frame-${stamp}.txt`);
        }
        return paths;
    }

    function ingest(catalogue: string): void {
        const lines = catalogue.split("\n");
        const parsed = [];
        for (let index = 0; index < root.frameCount; index++) {
            const start = index * root.frameLines;
            parsed.push(lines.slice(start, start + root.frameLines));
        }
        root.frames = parsed;
    }

    function glyph(): string {
        return Screensaver.glyphAlphabet.charAt(Math.floor(
            Math.random() * Screensaver.glyphAlphabet.length));
    }

    function reshuffle(): void {
        const jumbled = ({});
        const art = root.frames[root.frame] ?? [];
        for (let row = 0; row < art.length; row++) {
            const line = art[row];
            for (let col = 0; col < line.length; col++) {
                if (line[col] === " ") continue;
                if (Math.random() >= root.chaos) continue;
                jumbled[`${row}:${col}`] = root.glyph();
            }
        }
        root.mask = jumbled;
    }

    function scrambled(row: int, line: string): string {
        let cells = "";
        for (let col = 0; col < line.length; col++) {
            cells += root.mask[`${row}:${col}`] ?? line[col];
        }
        return cells;
    }

    function blockText(block: var): string {
        const art = root.frames[root.frame];
        if (!art) return "";
        const rows = [];
        for (let row = block.from; row <= block.to; row++) {
            rows.push(root.scrambled(row, art[row] ?? ""));
        }
        return rows.join("\n");
    }

    onChaosChanged: if (root.chaos === 0) root.mask = ({})

    Process {
        running: true
        command: ["cat"].concat(root.framePaths())

        stdout: StdioCollector {
            onStreamFinished: root.ingest(this.text)
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Screensaver.ground
    }

    Column {
        id: art

        x: (root.width - art.width) * root.across
        y: (root.height - art.height) * root.down
        opacity: root.artOpacity

        Repeater {
            model: root.blockRows

            Text {
                required property var modelData

                text: root.blockText(this.modelData)
                color: Theme.palette[this.modelData.role] ?? "white"
                lineHeight: root.lineStep
                lineHeightMode: Text.FixedHeight
                font.family: Theme.fonts.mono ?? ""
                font.pixelSize: root.glyphSize
            }
        }
    }

    Timer {
        running: root.turning && root.visible
            && root.frames.length > 0
        interval: root.turnMs
        repeat: true

        onTriggered: root.frame = (root.frame + 1) % root.frameCount
    }

    Timer {
        running: root.chaos > 0 && root.visible
        interval: root.churnMs
        repeat: true
        triggeredOnStart: true

        onTriggered: root.reshuffle()
    }

    SequentialAnimation on chaos {
        running: root.turning && root.visible
        loops: Animation.Infinite

        PauseAnimation {
            duration: root.holdMs
        }

        NumberAnimation {
            from: 0
            to: 1
            duration: root.meltMs
        }

        PauseAnimation {
            duration: root.meltedMs
        }

        NumberAnimation {
            from: 1
            to: 0
            duration: root.meltMs
        }
    }
}
