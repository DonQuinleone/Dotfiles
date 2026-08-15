import QtQuick
import qs.services

Column {
    id: root

    required property string kind

    readonly property var rows: AudioDevices.rows(root.kind)

    spacing: Theme.spacing.hair ?? 0

    Text {
        visible: root.rows.length === 0
        text: "No devices available"
        color: Theme.palette.fgDim ?? "white"
        font.family: Theme.fonts.ui ?? ""
        font.pixelSize: Theme.fontSizes.normal ?? 0
    }

    Repeater {
        model: root.rows

        AudioPickerRow {
            required property var modelData

            width: root.width
            label: this.modelData.label
            current: this.modelData.current

            onChosen: AudioDevices.use(root.kind,
                this.modelData.value)
        }
    }
}
