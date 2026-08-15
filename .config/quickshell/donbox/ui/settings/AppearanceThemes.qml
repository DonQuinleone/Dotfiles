import QtQuick
import qs.services

Column {
    id: root

    readonly property real listShare: 0.56

    readonly property var items: ThemeCatalogue.themes.map(theme => ({
        value: theme.slug,
        label: theme.name,
        detail: theme.slug,
        current: theme.current
    }))

    readonly property string active: ThemeCatalogue.active

    property string previewed: root.active

    spacing: Theme.spacing.tight ?? 0

    onItemsChanged: list.locate(root.active)
    onActiveChanged: list.locate(root.active)

    SettingsRow {
        width: parent.width
        label: qsTr("Theme")
        hint: qsTr("Moving through the list draws the theme "
            + "beside it. Press Enter, or the button below, to "
            + "change to it.")

        Row {
            width: parent.width
            spacing: Theme.spacing.loose ?? 0

            SettingsList {
                id: list

                width: Math.round(
                    (parent.width - parent.spacing) * root.listShare)
                items: root.items

                onHighlighted: value => root.previewed = value
                onChosen: value => ThemeCatalogue.commit(value)
            }

            ThemePreviewCard {
                width: parent.width - list.width - parent.spacing
                height: list.height
                slug: root.previewed
            }
        }
    }

    SettingsButton {
        label: qsTr("Change to this theme")
        glyph: "󰄬"

        onActivated: ThemeCatalogue.commit(
            root.items[list.index]?.value ?? root.active)
    }

    SettingsNote {
        width: parent.width
        warning: true
        text: ThemeCatalogue.message
    }
}
