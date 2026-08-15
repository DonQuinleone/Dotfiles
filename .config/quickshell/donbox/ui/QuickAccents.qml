import QtQuick
import qs.services

Flow {
    id: root

    readonly property var names: Object.keys(Theme.accents)

    spacing: Theme.spacing.tight ?? 0

    Repeater {
        model: root.names

        QuickAccentChip {
            required property string modelData

            name: this.modelData
            swatch: Theme.accents[this.modelData]
            selected: Qt.colorEqual(Theme.palette.accent ?? "black",
                Theme.accents[this.modelData])

            onActivated: Theme.applyAccent(this.modelData)
        }
    }
}
