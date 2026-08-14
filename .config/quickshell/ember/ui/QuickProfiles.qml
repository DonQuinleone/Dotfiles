import QtQuick
import qs.services

Flow {
    id: root

    spacing: Theme.spacing.tight ?? 0

    Repeater {
        model: PowerMode.options

        QuickChip {
            required property var modelData

            glyph: this.modelData.glyph
            label: this.modelData.label
            selected: PowerMode.current === this.modelData.profile

            onActivated: PowerMode.select(this.modelData.profile)
        }
    }
}
