import QtQuick

QtObject {
    id: root

    readonly property real fullTurn: Math.PI * 2
    readonly property real grainSpread: 1000

    readonly property var kinds: ({
        crossfade: 0,
        wipe: 1,
        grow: 2,
        shrink: 3,
        dissolve: 4,
        pixelate: 5,
        wave: 6
    })

    readonly property var crossfade:
        ({ kind: root.kinds.crossfade, beats: 1, curve: "standard" })

    readonly property var repertoire: [
        { kind: root.kinds.wipe, beats: 3, curve: "standard" },
        { kind: root.kinds.grow, beats: 4, curve: "standard" },
        { kind: root.kinds.shrink, beats: 4, curve: "standard" },
        { kind: root.kinds.dissolve, beats: 5, curve: "linear" },
        { kind: root.kinds.pixelate, beats: 4, curve: "standard" },
        { kind: root.kinds.wave, beats: 4, curve: "standard" }
    ]

    function anyOf(choices: var): var {
        return choices[Math.floor(Math.random() * choices.length)];
    }

    function next(plain: bool): var {
        const chosen =
            plain ? root.crossfade : root.anyOf(root.repertoire);
        return {
            kind: chosen.kind,
            beats: chosen.beats,
            curve: chosen.curve,
            angle: Math.random() * root.fullTurn,
            origin: Qt.point(Math.random(), Math.random()),
            grain: Math.random() * root.grainSpread
        };
    }
}
