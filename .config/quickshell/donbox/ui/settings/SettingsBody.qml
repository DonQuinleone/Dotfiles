import QtQuick
import qs.services

FocusScope {
    id: root

    readonly property int padding: Theme.sizes.popupPadding ?? 0

    readonly property var pages: ({
        "appearance": appearance,
        "magnifier": magnifier,
        "nightshift": nightshift,
        "monitors": monitors,
        "audio": audio,
        "bluetooth": bluetooth,
        "notifications": notifications,
        "devices": devices,
        "power": power,
        "autostart": autostart,
        "bindings": bindings
    })

    Column {
        id: heading

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: root.padding
        spacing: Theme.spacing.hair ?? 0

        Text {
            width: parent.width
            text: Settings.panes[Settings.current].title
            color: Theme.palette.fg ?? "white"
            font.family: Theme.fonts.ui ?? ""
            font.pixelSize: Metrics.settingsTitleSize
            font.weight: Theme.fontWeights.bold ?? 0
        }

        SettingsNote {
            width: parent.width
            text: qsTr("Up and Down choose a pane, Tab moves "
                + "through the controls, Escape closes.")
        }
    }

    SettingsScroller {
        anchors.top: heading.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: root.padding

        Loader {
            width: parent.width
            sourceComponent: root.pages[Settings.pane]
        }
    }

    Component {
        id: appearance

        AppearancePane {}
    }

    Component {
        id: magnifier

        MagnifierPane {}
    }

    Component {
        id: nightshift

        NightShiftPane {}
    }

    Component {
        id: monitors

        MonitorsPane {}
    }

    Component {
        id: audio

        AudioPane {}
    }

    Component {
        id: bluetooth

        BluetoothPane {}
    }

    Component {
        id: notifications

        NotificationsPane {}
    }

    Component {
        id: devices

        DevicesPane {}
    }

    Component {
        id: power

        PowerPane {}
    }

    Component {
        id: autostart

        AutostartPane {}
    }

    Component {
        id: bindings

        BindingsPane {}
    }
}
