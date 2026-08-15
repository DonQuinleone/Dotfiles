import QtQuick
import qs.services

Column {
    id: root

    readonly property var options: Object.keys(Theme.accents)
        .map(name => ({ value: name, label: root.titled(name) }))

    readonly property string current: Object.keys(Theme.accents)
        .find(name => Qt.colorEqual(Theme.palette.accent ?? "black",
            Theme.accents[name])) ?? ""

    spacing: Theme.spacing.tight ?? 0

    function titled(name: string): string {
        return name.charAt(0).toUpperCase() + name.slice(1);
    }

    SettingsRow {
        width: parent.width
        label: qsTr("Accent")
        hint: qsTr("The theme refuses an accent that would be too "
            + "faint against its background.")

        SettingsChoice {
            width: parent.width
            options: root.options
            current: root.current

            onChosen: wanted => ThemeCatalogue.applyAccent(wanted)
        }
    }
}
