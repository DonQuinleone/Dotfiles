import QtQuick
import qs.services

BarPill {
    id: root

    readonly property string label: "ZOOM"

    visible: CursorZoom.magnified

    content: [
        PillText {
            text: root.label
            color: Theme.palette.fgDim ?? "white"
            font.pixelSize: Theme.fontSizes.small ?? 0
            font.weight: Theme.fontWeights.regular ?? 0
            font.letterSpacing: Theme.spacing.hair ?? 0
        },
        PillText {
            text: `${CursorZoom.percent}%`
            color: Theme.palette.fgDim ?? "white"
            font.pixelSize: Theme.fontSizes.small ?? 0
        }
    ]
}
