import QtQuick
import qs.services

BarPill {
    id: root

    visible: Updates.offered

    content: [
        PillText {
            text: Updates.glyph
            color: Theme.palette.warn ?? "white"
            font.pixelSize: Theme.sizes.iconNormal ?? 0
        },
        PillText {
            text: Updates.countText
            color: Theme.palette.warn ?? "white"
        }
    ]
}
