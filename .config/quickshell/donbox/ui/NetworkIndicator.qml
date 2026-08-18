import QtQuick
import Quickshell
import qs.services

BarPill {
    id: root

    visible: Connectivity.available
    highlighted: panel.visible

    content: [
        PillText {
            text: Connectivity.glyph
            color: Connectivity.tint
            font.pixelSize: Theme.sizes.iconNormal ?? 0
        }
    ]

    PanelToggle {
        surface: panel
    }

    NetworkPanel {
        id: panel

        name: "network"

        under: root
    }
}
