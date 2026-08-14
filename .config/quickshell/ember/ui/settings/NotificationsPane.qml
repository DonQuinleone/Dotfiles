import QtQuick
import qs.services

Column {
    id: root

    readonly property string silentSound: "info"

    spacing: Theme.spacing.loose ?? 0

    SettingsCard {
        width: parent.width
        title: qsTr("Interruptions")

        SettingsRow {
            width: parent.width
            label: qsTr("Do not disturb")
            hint: qsTr("Holds everything but critical notifications "
                + "in the centre, silently.")

            SettingsToggle {
                width: parent.width
                checked: NotificationStore.doNotDisturb

                onActivated: NotificationStore.toggleDoNotDisturb()
            }
        }
    }

    SettingsCard {
        width: parent.width
        title: qsTr("Default sounds")

        NotificationDefaults {
            width: parent.width
        }
    }

    SettingsCard {
        width: parent.width
        title: qsTr("Applications")

        Column {
            width: parent.width
            spacing: Theme.spacing.section ?? 0

            Repeater {
                model: NotificationSettings.applications

                NotificationRuleCard {
                    required property string modelData

                    width: parent.width
                    app: this.modelData
                }
            }

            SettingsNote {
                width: parent.width
                visible: NotificationSettings.applications.length === 0
                text: qsTr("No application has a rule of its own yet.")
            }
        }
    }

    SettingsCard {
        width: parent.width
        visible: NotificationSettings.unruled.length > 0
        title: qsTr("Seen recently")

        SettingsRow {
            width: parent.width
            label: qsTr("Give one of these a rule")
            hint: qsTr("Applications that have sent a notification "
                + "but have no sound or spoken words set.")

            Flow {
                width: parent.width
                spacing: Theme.spacing.tight ?? 0

                Repeater {
                    model: NotificationSettings.unruled

                    SettingsButton {
                        required property string modelData

                        label: this.modelData
                        glyph: "󰐕"

                        onActivated: NotificationSettings.setRule(
                            this.modelData, "sound", root.silentSound)
                    }
                }
            }
        }
    }
}
