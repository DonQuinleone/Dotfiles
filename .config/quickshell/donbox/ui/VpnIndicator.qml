import QtQuick
import qs.services

BarPill {
    id: root

    visible: Vpn.available

    content: [
        PillText {
            text: Vpn.glyph
            color: Vpn.tint
            font.pixelSize: Theme.sizes.iconNormal ?? 0
        }
    ]
}
