import QtQuick
import qs.services

BarPill {
    id: root

    readonly property real labelWidthFactor: 0.45
    readonly property int labelCeiling:
        (Theme.sizes.menuWidth ?? 0) * root.labelWidthFactor

    readonly property var reading: BluetoothRadio.lowestReading
    readonly property int percent: BluetoothRadio.lowestPercent

    visible: BluetoothRadio.available

    content: [
        PillText {
            text: BluetoothRadio.glyph
            color: BluetoothRadio.tint
            font.pixelSize: Theme.sizes.iconNormal ?? 0
        },
        PillText {
            width: Math.min(this.implicitWidth, root.labelCeiling)
            elide: Text.ElideRight
            text: BluetoothRadio.label
            color: BluetoothRadio.tint
        },
        PillText {
            text: Battery.glyphFor(root.percent)
            visible: root.reading !== null
            color: Battery.tintFor(root.percent)
            font.pixelSize: Theme.sizes.iconNormal ?? 0
        },
        PillText {
            text: `${root.percent}%`
            visible: root.reading !== null
            color: Battery.tintFor(root.percent)
        }
    ]
}
