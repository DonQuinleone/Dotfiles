import QtQuick
import qs.services

Flow {
    id: root

    spacing: Theme.spacing.tight ?? 0

    Repeater {
        model: NetworkResolvers.providers

        QuickChip {
            required property var modelData

            label: this.modelData.label
            selected: NetworkResolvers.chosenLabel
                === this.modelData.label
            opacity: NetworkResolvers.applying
                ? (Theme.opacities.dim ?? 1)
                : (Theme.opacities.full ?? 1)

            onActivated: NetworkResolvers.choose(this.modelData)
        }
    }
}
