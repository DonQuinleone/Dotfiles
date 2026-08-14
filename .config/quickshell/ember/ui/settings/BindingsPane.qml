import QtQuick
import qs.services

Column {
    id: root

    readonly property var groups: KeyBindings.filtered(search.text)

    readonly property int total: root.groups
        .reduce((count, group) => count + group.rows.length, 0)

    spacing: Theme.spacing.loose ?? 0

    SettingsCard {
        width: parent.width
        title: qsTr("Keyboard shortcuts")

        SettingsRow {
            width: parent.width
            label: qsTr("Search")
            hint: qsTr("Filters as you type, on the keys and on "
                + "what they do.")

            SettingsField {
                id: search

                width: parent.width
                placeholder: qsTr("Every shortcut")
            }
        }

        SettingsNote {
            width: parent.width
            text: qsTr("%1 shortcuts, read from the running "
                + "compositor.").arg(root.total)
        }
    }

    Repeater {
        model: root.groups

        BindingGroup {
            required property var modelData

            width: root.width
            group: this.modelData
        }
    }

    SettingsNote {
        width: parent.width
        visible: root.total === 0
        text: qsTr("Nothing matches that search.")
    }
}
