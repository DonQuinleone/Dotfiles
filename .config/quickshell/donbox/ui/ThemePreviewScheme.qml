import QtQuick

QtObject {
    id: root

    property var data: ({})

    readonly property var palette: root.data.palette ?? ({})
    readonly property var fonts: root.data.fonts ?? ({})
    readonly property var fontSizes: root.data.fontSizes ?? ({})
    readonly property var fontWeights: root.data.fontWeights ?? ({})
    readonly property var radii: root.data.radii ?? ({})
    readonly property var spacing: root.data.spacing ?? ({})
    readonly property var sizes: root.data.sizes ?? ({})
    readonly property var accents: root.data.accents ?? ({})

    readonly property string name: root.data.name ?? ""

    readonly property color bg: root.palette.bg ?? "black"
    readonly property color bgAlt: root.palette.bgAlt ?? root.bg
    readonly property color surface:
        root.palette.surface ?? root.bgAlt
    readonly property color fg: root.palette.fg ?? "white"
    readonly property color fgDim: root.palette.fgDim ?? root.fg
    readonly property color accent: root.palette.accent ?? root.fg
    readonly property color border:
        root.palette.border ?? root.surface
    readonly property color good: root.palette.good ?? root.accent
    readonly property color warn: root.palette.warn ?? root.accent
    readonly property color bad: root.palette.bad ?? root.accent

    readonly property string ui: root.fonts.ui ?? ""
    readonly property string mono: root.fonts.mono ?? ""
}
