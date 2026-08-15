import QtQuick
import qs.services

Column {
    id: root

    readonly property int previewDelayMs: 250

    readonly property var items: ThemeCatalogue.themes.map(theme => ({
        value: theme.slug,
        label: theme.name,
        detail: theme.slug,
        current: theme.current
    }))

    property string pending: ""

    spacing: Theme.spacing.tight ?? 0

    onItemsChanged: list.locate(ThemeCatalogue.active)

    SettingsRow {
        width: parent.width
        label: qsTr("Theme")
        hint: qsTr("Moving through the list previews the theme on "
            + "the desktop. Press Enter, or the button below, to "
            + "keep it.")

        SettingsList {
            id: list

            width: parent.width
            items: root.items

            onHighlighted: value => {
                root.pending = value;
                preview.restart();
            }
            onChosen: value => ThemeCatalogue.commit(value)
        }
    }

    SettingsButton {
        label: qsTr("Keep this theme")
        glyph: "󰄬"

        onActivated: ThemeCatalogue.commit(
            root.items[list.index]?.value ?? ThemeCatalogue.active)
    }

    SettingsNote {
        width: parent.width
        warning: true
        text: ThemeCatalogue.message
    }

    Timer {
        id: preview

        interval: root.previewDelayMs

        onTriggered: ThemeCatalogue.preview(root.pending)
    }
}
