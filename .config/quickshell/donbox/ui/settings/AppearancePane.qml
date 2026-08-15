import QtQuick
import qs.services

Column {
    id: root

    spacing: Theme.spacing.loose ?? 0

    SettingsCard {
        width: parent.width
        title: qsTr("Theme")

        AppearanceThemes {
            width: parent.width
        }

        AppearanceAccents {
            width: parent.width
        }
    }

    SettingsCard {
        width: parent.width
        title: qsTr("Wallpaper")

        AppearanceWallpapers {
            width: parent.width
        }
    }

    SettingsCard {
        width: parent.width
        title: qsTr("Motion")

        AppearanceMotion {
            width: parent.width
        }
    }
}
