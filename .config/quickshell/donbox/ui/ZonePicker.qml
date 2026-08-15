import QtQuick
import qs.services

Column {
    id: root

    property string region: ""

    spacing: Theme.spacing.tight ?? 0

    Flow {
        width: parent.width
        spacing: Theme.spacing.tight ?? 0

        Repeater {
            model: WorldClocks.regions

            QuickChip {
                required property string modelData

                label: this.modelData
                selected: root.region === this.modelData

                onActivated: root.region = root.region
                    === this.modelData ? "" : this.modelData
            }
        }
    }

    Flow {
        width: parent.width
        spacing: Theme.spacing.tight ?? 0

        Repeater {
            model: root.region === ""
                ? []
                : WorldClocks.citiesIn(root.region)

            QuickChip {
                required property string modelData

                label: WorldClocks.labelOf(this.modelData)
                selected: WorldClocks.holds(this.modelData)

                onActivated: WorldClocks.add(this.modelData)
            }
        }
    }
}
