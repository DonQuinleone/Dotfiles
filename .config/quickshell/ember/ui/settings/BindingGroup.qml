import QtQuick
import qs.services

SettingsCard {
    id: root

    required property var group

    title: root.group.name

    Column {
        width: parent.width
        spacing: Theme.spacing.normal ?? 0

        Repeater {
            model: root.group.rows

            BindingRow {
                required property var modelData

                width: parent.width
                binding: this.modelData
            }
        }
    }
}
