import QtQuick
import qs.services

Column {
    id: root

    spacing: Theme.spacing.normal ?? 0

    Text {
        visible: BluetoothRadio.known.length === 0
        text: "No paired devices"
        color: Theme.palette.fgDim ?? "white"
        font.family: Theme.fonts.ui ?? ""
        font.pixelSize: Theme.fontSizes.normal ?? 0
    }

    Repeater {
        model: BluetoothRadio.known

        QuickDeviceRow {
            required property var modelData

            width: root.width
            device: this.modelData
        }
    }
}
