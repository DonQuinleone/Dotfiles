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
        surface: panel
    }

    BluetoothPanel {
        id: panel

        name: "bluetooth"

        under: root
    }
}
