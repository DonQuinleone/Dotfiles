import QtQuick
import qs.services

Column {
    id: root

    readonly property var profileOptions: PowerMode.options
        .map(choice => ({
            value: choice.profile,
            label: choice.label,
            glyph: choice.glyph
        }))

    readonly property var saverLabels: ({
        lava: qsTr("Lava lamp"),
        windmill: qsTr("Windmill"),
        rain: qsTr("Falling glyphs"),
        cycle: qsTr("A different one each time"),
        off: qsTr("None")
    })

    readonly property var saverOptions: Screensaver.saverNames
        .concat(Screensaver.modeNames)
        .map(name => ({
            value: name,
            label: root.saverLabels[name] ?? name
        }))

    readonly property var screensaverStep: IdleProfile.rows
        .find(step => step.token === "idle-screensaver")

    readonly property string screensaverWords: root.screensaverStep
        ? qsTr("The timings in force start it after %1.")
            .arg(IdleProfile.spell(root.screensaverStep.seconds))
        : qsTr("The timings in force never start it.")

    readonly property var lidRules: [
        { docked: true, held: true, warning: false,
          words: qsTr("Closing the lid switches the laptop panel "
            + "off and leaves the session running on the external "
            + "screen.") },
        { docked: true, held: false, warning: true,
          words: qsTr("An external screen is attached, but nothing "
            + "is holding the lid switch, so closing the lid would "
            + "suspend the machine.") },
        { docked: false, held: false, warning: false,
          words: qsTr("Closing the lid suspends the machine.") },
        { docked: false, held: true, warning: true,
          words: qsTr("The lid switch is still held from a docked "
            + "session, so closing the lid would only switch the "
            + "laptop panel off.") }
    ]

    readonly property var lidRule: root.lidRules.find(rule =>
        rule.docked === IdleProfile.docked
        && rule.held === LidSwitch.held)

    spacing: Theme.spacing.loose ?? 0

    function reread(): void {
        IdleProfile.refresh();
        LidSwitch.refresh();
    }

    Component.onCompleted: root.reread()

    SettingsCard {
        width: parent.width
        title: qsTr("Power")

        SettingsRow {
            width: parent.width
            visible: PowerMode.available
            label: qsTr("Power profile")
            hint: qsTr("Trades speed for quiet running and battery "
                + "life.")

            SettingsChoice {
                width: parent.width
                options: root.profileOptions
                current: PowerMode.current

                onChosen: wanted => PowerMode.select(wanted)
            }
        }

        SettingsNote {
            width: parent.width
            visible: !PowerMode.available
            warning: true
            text: qsTr("The power profile service is not answering, "
                + "so the profile cannot be read or changed.")
        }

        PowerBatteryRow {
            width: parent.width
        }
    }

    SettingsCard {
        width: parent.width
        title: qsTr("When the session is left alone")

        SettingsNote {
            width: parent.width
            visible: IdleProfile.running
            text: qsTr("The %1 timings are in force, read from %2. "
                + "Which set applies follows the screens attached.")
                .arg(IdleProfile.title).arg(IdleProfile.configName)
        }

        SettingsNote {
            width: parent.width
            visible: !IdleProfile.running
            warning: true
            text: qsTr("The idle timer is not running, so nothing "
                + "happens when the session is left alone.")
        }

        Column {
            width: parent.width
            spacing: Theme.spacing.normal ?? 0

            Repeater {
                model: IdleProfile.rows

                PowerIdleRow {
                    required property var modelData

                    width: parent.width
                    step: this.modelData
                }
            }
        }

        SettingsNote {
            width: parent.width
            visible: IdleProfile.running
                && IdleProfile.rows.length === 0
            text: qsTr("No timings could be read from that file.")
        }

        SettingsNote {
            width: parent.width
            visible: IdleProfile.running && !IdleProfile.matched
            warning: true
            text: qsTr("These are not the timings for the screens "
                + "attached now: the %1 set would be.")
                .arg(IdleProfile.wanted.title)
        }

        Flow {
            width: parent.width
            spacing: Theme.spacing.tight ?? 0

            SettingsButton {
                label: qsTr("Look again")
                glyph: "󰑐"

                onActivated: root.reread()
            }

            SettingsButton {
                label: qsTr("Use the timings for these screens")
                glyph: "󰦛"

                onActivated: IdleProfile.apply()
            }
        }
    }

    SettingsCard {
        width: parent.width
        title: qsTr("Screensaver")

        SettingsRow {
            width: parent.width
            label: qsTr("What to show")
            hint: qsTr("Chosen afresh each time the screensaver "
                + "starts.")

            SettingsChoice {
                width: parent.width
                options: root.saverOptions
                current: Screensaver.choice

                onChosen: wanted => Screensaver.select(wanted)
            }
        }

        SettingsNote {
            width: parent.width
            text: root.screensaverWords
        }
    }

    SettingsCard {
        width: parent.width
        title: qsTr("Closing the lid")

        SettingsNote {
            width: parent.width
            warning: root.lidRule.warning
            text: root.lidRule.words
        }

        SettingsNote {
            width: parent.width
            text: qsTr("The rule follows the screens on its own, "
                + "whenever one is plugged in or unplugged.")
        }

        SettingsButton {
            label: qsTr("Match the rule to the screens")
            glyph: "󰦛"

            onActivated: LidSwitch.sync()
        }
    }
}
