import QtQuick
import Quickshell
import qs.services

FloatingWindow {
    id: root

    readonly property int divider: Theme.sizes.borderWidth ?? 0

    title: qsTr("Donbox settings")
    visible: Settings.shown
    color: Theme.palette.bg ?? "black"
    implicitWidth: Metrics.settingsWidth
    implicitHeight: Metrics.settingsHeight
    minimumSize: Qt.size(Metrics.settingsMinimumWidth,
        Metrics.settingsMinimumHeight)

    onVisibleChanged: {
        if (!root.visible) {
            Settings.hide();
            return;
        }
        root.gather();
        nav.forceActiveFocus();
    }

    function gather(): void {
        Accessibility.refresh();
        InputDevices.refresh();
        MonitorProfiles.refresh();
        IdleProfile.refresh();
        LidSwitch.refresh();
        KeyBindings.refresh();
        ThemeCatalogue.refresh();
        Motion.refresh();
    }

    FocusScope {
        anchors.fill: parent
        focus: true

        Keys.onEscapePressed: Settings.hide()

        SettingsNav {
            id: nav

            anchors.top: parent.top
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            width: Metrics.settingsNavWidth
        }

        Rectangle {
            id: edge

            anchors.top: parent.top
            anchors.left: nav.right
            anchors.bottom: parent.bottom
            width: root.divider
            color: Theme.palette.border ?? "transparent"
        }

        SettingsBody {
            anchors.top: parent.top
            anchors.left: edge.right
            anchors.right: parent.right
            anchors.bottom: parent.bottom
        }
    }
}
