import QtQuick
import qs.services

Column {
    id: root

    spacing: Theme.spacing.loose ?? 0

    SettingsCard {
        width: parent.width
        title: qsTr("What starts with the session")

        SettingsNote {
            width: parent.width
            text: qsTr("From the compositor: %1. Desktop "
                + "entries: %2. User units: %3.")
                .arg(Autostart.compositor.length)
                .arg(Autostart.entries.length)
                .arg(Autostart.units.length)
        }

        SettingsButton {
            label: qsTr("Look again")
            glyph: "󰑐"

            onActivated: Autostart.refresh()
        }
    }

    SettingsCard {
        width: parent.width
        title: qsTr("Started by the compositor")

        SettingsNote {
            width: parent.width
            text: qsTr("Hyprland runs these as it starts. They "
                + "live in autostart.lua, which is kept under "
                + "version control, so this list is read-only: "
                + "edit that file to change it.")
        }

        Repeater {
            model: Autostart.compositor

            AutostartCommand {
                required property string modelData

                width: parent.width
                text: this.modelData
            }
        }
    }

    SettingsCard {
        width: parent.width
        title: qsTr("Desktop entries")

        SettingsNote {
            width: parent.width
            warning: !Autostart.xdgHonoured
            text: Autostart.xdgHonoured
                ? qsTr("Started with the session through "
                    + "xdg-desktop-autostart.target.")
                : qsTr("Nothing in this session starts these: "
                    + "xdg-desktop-autostart.target is not "
                    + "running. Blocking one is still recorded, "
                    + "and holds anywhere these are read.")
        }

        SettingsNote {
            width: parent.width
            text: qsTr("Read from %1.")
                .arg(Autostart.searchPaths.join(", "))
        }

        Repeater {
            model: Autostart.entries

            AutostartEntryRow {
                required property var modelData

                width: parent.width
                entry: this.modelData
            }
        }

        SettingsNote {
            width: parent.width
            visible: Autostart.entries.length === 0
            text: qsTr("There are no entries in those folders.")
        }
    }

    SettingsCard {
        width: parent.width
        title: qsTr("User services")

        SettingsNote {
            width: parent.width
            text: qsTr("Units systemd has enabled for you. "
                + "Enable or disable one with systemctl --user.")
        }

        Repeater {
            model: Autostart.units

            AutostartUnitRow {
                required property var modelData

                width: parent.width
                unit: this.modelData
            }
        }
    }
}
