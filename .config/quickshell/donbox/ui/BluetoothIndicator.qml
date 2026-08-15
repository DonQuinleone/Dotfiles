import QtQuick
import Quickshell
import qs.services

BarPill {
    id: root

    highlighted: panel.visible
    visible: BluetoothRadio.available

    content: [
        PillText {
            text: BluetoothRadio.glyph
            color: BluetoothRadio.tint
            font.pixelSize: Theme.sizes.iconNormal ?? 0
        }
    ]

    PanelToggle {
        name: "bluetooth"
        surface: panel
    }

    BluetoothPanel {
        id: panel

        anchor.item: root
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom
    }
}
