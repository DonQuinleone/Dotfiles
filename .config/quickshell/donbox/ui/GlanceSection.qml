import QtQuick
import qs.services

Column {
    id: root

    required property string title
    required property var rows
    required property var figures

    spacing: Theme.spacing.normal ?? 0

    Text {
        text: root.title
        color: Theme.palette.accent ?? "white"
        font.family: Theme.fonts.ui ?? ""
        font.pixelSize: Theme.fontSizes.large ?? 0
        font.weight: Theme.fontWeights.bold ?? 0
    }

    Repeater {
        model: root.rows

        GlanceRow {
            required property var modelData

            width: root.width
            label: this.modelData.label
            value: root.figures[this.modelData.key] ?? ""
        }
    }
}
