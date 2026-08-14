import QtQuick
import qs.services

Column {
    id: root

    readonly property var groups: KeyBindings.filtered(search.text)

    readonly property int total: root.groups
        .reduce((count, group) => count + group.rows.length, 0)

    readonly property int described: root.groups
        .reduce((count, group) => count + group.rows
            .filter(row => row.description !== "").length, 0)

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
                placeholder: qsTr("Type to filter")
            }
        }

        SettingsNote {
            width: parent.width
            text: qsTr("%1 shortcuts, read from the running "
                + "compositor.").arg(root.total)
        }

        SettingsNote {
            width: parent.width
            visible: root.described === 0
            text: qsTr("None of them carries a description yet: "
                + "the compositor only reports one when the "
                + "binding is given it.")
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
