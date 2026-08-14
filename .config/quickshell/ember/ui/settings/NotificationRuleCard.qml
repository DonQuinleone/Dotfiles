import QtQuick
import qs.services

Column {
    id: root

    required property string app

    readonly property var rule: NotificationSettings.ruleFor(root.app)
    readonly property string normalUrgency: "normal"

    spacing: Theme.spacing.normal ?? 0

    function remember(field: string, written: string): void {
        NotificationSettings.setRule(root.app, field,
            written === "" ? undefined : written);
    }

    SettingsRow {
        width: parent.width
        label: root.app
        hint: qsTr("Sound played when this application sends a "
            + "notification.")

        NotificationSoundChoice {
            width: parent.width
            sound: root.rule.sound

            onChosen: wanted => NotificationSettings.setRule(
                root.app, "sound", wanted)
        }
    }

    SettingsRow {
        width: parent.width
        label: qsTr("Spoken words")
        hint: qsTr("{summary}, {body} and {app} are filled in from "
            + "the notification. Empty says nothing.")

        SettingsField {
            width: parent.width
            text: root.rule.speak ?? ""
            placeholder: qsTr("Say nothing")

            onAccepted: written => root.remember("speak", written)
        }
    }

    Row {
        spacing: Theme.spacing.tight ?? 0

        SettingsButton {
            label: qsTr("Test")
            glyph: "󰋋"

            onActivated: NotificationSettings.test(
                root.app, root.normalUrgency)
        }

        SettingsButton {
            label: qsTr("Forget")
            glyph: "󰺝"

            onActivated: NotificationSettings.forgetRule(root.app)
        }
    }
}
