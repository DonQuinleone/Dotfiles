import QtQuick
import qs.services

BarPill {
    id: root

    visible: BluetoothRadio.available

    content: [
        PillText {
            text: BluetoothRadio.glyph
            color: BluetoothRadio.tint
            font.pixelSize: Theme.sizes.iconNormal ?? 0
        }
    ]
}
