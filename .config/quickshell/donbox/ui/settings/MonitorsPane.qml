import QtQuick
import Quickshell.Hyprland
import qs.services

Column {
    id: root

    readonly property string profileHeadline:
        MonitorProfiles.matchedName !== ""
            ? qsTr("Using %1").arg(MonitorProfiles.matchedName)
            : qsTr("No saved profile matches these screens")

    readonly property string profileHint:
        MonitorProfiles.matchedName !== ""
            ? qsTr("Applied when the session starts and whenever "
                + "a screen is plugged in.")
            : qsTr("The fallback settings in the Hyprland config "
                + "stay in force until a profile matches.")

    spacing: Theme.spacing.loose ?? 0

    function readAgain(): void {
        Hyprland.refreshMonitors();
        Hyprland.refreshWorkspaces();
        MonitorProfiles.refresh();
    }

    function screenWords(count: int): string {
        if (count === 1) return qsTr("one screen");
        return qsTr("%1 screens").arg(count);
    }

    function profileLine(profile: var): string {
        const shape = root.screenWords(profile.outputs);
        if (profile.matched) {
            return qsTr("%1, %2, matching now")
                .arg(profile.name).arg(shape);
        }
        return qsTr("%1, %2").arg(profile.name).arg(shape);
    }

    SettingsCard {
        width: parent.width
        title: qsTr("Monitors")

        SettingsNote {
            width: parent.width
            text: qsTr("Read from the compositor. Modes, scales "
                + "and positions come from the monitor profile in "
                + "force, not from here.")
        }

        SettingsButton {
            label: qsTr("Look again")
            glyph: "󰑐"

            onActivated: root.readAgain()
        }
    }

    Repeater {
        model: Hyprland.monitors.values

        MonitorCard {
            required property var modelData

            width: root.width
            monitor: this.modelData
        }
    }

    SettingsCard {
        width: parent.width
        title: qsTr("Monitor profile")

        SettingsNote {
            width: parent.width
            text: qsTr("A profile remembers the mode, scale, "
                + "position and workspaces of a set of screens, "
                + "matched by the description each one reports.")
        }

        SettingsRow {
            width: parent.width
            label: root.profileHeadline
            hint: root.profileHint

            SettingsButton {
                label: MonitorProfiles.detecting
                    ? qsTr("Detecting…")
                    : qsTr("Detect again")
                glyph: "󰍹"

                onActivated: MonitorProfiles.detect()
            }
        }

        SettingsNote {
            width: parent.width
            warning: true
            text: MonitorProfiles.trouble
        }

        SettingsRow {
            width: parent.width
            label: qsTr("Saved profiles")

            Repeater {
                model: MonitorProfiles.profiles

                SettingsNote {
                    required property var modelData

                    width: parent.width
                    text: root.profileLine(this.modelData)
                }
            }

            SettingsNote {
                width: parent.width
                visible: MonitorProfiles.profiles.length === 0
                text: qsTr("None saved yet. The monitor-profile "
                    + "save command remembers the screens as they "
                    + "are arranged now.")
            }
        }
    }
}
