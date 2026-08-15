import QtQuick
import qs.services

Column {
    id: root

    readonly property var options: Motion.speeds.map(speed => ({
        value: speed.scale,
        label: qsTr("%1× %2").arg(speed.scale).arg(speed.word)
    }))

    spacing: Theme.spacing.section ?? 0

    SettingsRow {
        width: parent.width
        label: qsTr("Animation speed")
        hint: qsTr("Scales how long windows, workspaces and the "
            + "magnifier take to move.")

        SettingsChoice {
            width: parent.width
            options: root.options
            current: Motion.scale

            onChosen: wanted => Motion.setScale(wanted)
        }
    }

    SettingsRow {
        width: parent.width
        label: qsTr("Reduce motion")
        hint: qsTr("Separate from the speed above: the springy "
            + "animations ignore speed, so this swaps them for "
            + "flat ones as well as shortening the rest.")

        SettingsToggle {
            width: parent.width
            checked: Motion.reduced

            onActivated: Motion.setReduced(!Motion.reduced)
        }
    }

    SettingsRow {
        width: parent.width
        label: qsTr("Drifting focus border")
        hint: qsTr("The accent border rotates slowly around the "
            + "focused window. It redraws every frame for as long "
            + "as the session lasts, so it costs battery.")

        SettingsToggle {
            width: parent.width
            checked: Motion.drift

            onActivated: Motion.setDrift(!Motion.drift)
        }
    }

    SettingsNote {
        width: parent.width
        warning: true
        visible: !Motion.available
        text: qsTr("The motion script is not answering, so these "
            + "choices are not being applied yet.")
    }

    SettingsNote {
        width: parent.width
        warning: true
        text: Motion.message
    }
}
