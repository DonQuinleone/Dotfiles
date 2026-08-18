import QtQuick
import Quickshell
import qs.services

BarPill {
    id: root

    highlighted: panel.visible
    visible: Vpn.available

    content: [
        PillText {
            text: Vpn.glyph
            color: Vpn.tint
            font.pixelSize: Theme.sizes.iconNormal ?? 0
        }
    ]

    PanelToggle {
        surface: panel
    }

    VpnPanel {
        id: panel

        name: "vpn"

        under: root
    }
}
