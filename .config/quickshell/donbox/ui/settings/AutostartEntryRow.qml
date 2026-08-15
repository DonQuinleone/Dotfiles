import QtQuick
import qs.services

SettingsRow {
    id: root

    required property var entry

    label: root.entry.name
    hint: root.entry.path

    AutostartCommand {
        width: parent.width
        text: root.entry.command
    }

    SettingsNote {
        width: parent.width
        warning: true
        text: root.entry.reason
    }

    Row {
        spacing: Theme.spacing.tight ?? 0

        SettingsToggle {
            checked: !root.entry.hidden
            onWord: qsTr("Allowed")
            offWord: qsTr("Blocked")

            onActivated: Autostart.setHidden(
                root.entry.id, !root.entry.hidden)
        }

        SettingsButton {
            visible: root.entry.userOwned
                && root.entry.systemBacked
            label: qsTr("Use the system copy")
            glyph: "󰦛"

            onActivated: Autostart.useSystemCopy(root.entry.id)
        }
    }
}
