import QtQuick
import qs.services

Column {
    id: root

    spacing: Theme.spacing.section ?? 0

    Repeater {
        model: NotificationSettings.urgencies

        Column {
            id: urgency

            required property var modelData

            readonly property var rule:
                NotificationSettings.defaultsFor(this.modelData.key)

            width: root.width
            spacing: Theme.spacing.tight ?? 0

            SettingsRow {
                width: parent.width
                label: qsTr("%1 urgency").arg(urgency.modelData.word)
                hint: qsTr("Played when the application has no "
                    + "sound of its own.")

                NotificationSoundChoice {
                    width: parent.width
                    sound: urgency.rule.sound

                    onChosen: wanted =>
                        NotificationSettings.setDefault(
                            urgency.modelData.key, "sound", wanted)
                }
            }

            SettingsButton {
                label: qsTr("Test")
                glyph: "󰋋"

                onActivated: NotificationSettings.test(
                    NotificationSettings.testApp,
                    urgency.modelData.key)
            }
        }
    }
}
