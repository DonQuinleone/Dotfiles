import QtQuick
import qs.services

SettingsChoice {
    id: root

    required property var sound

    readonly property var silent:
        ({ value: null, label: qsTr("Silent") })

    function titled(name: string): string {
        return name.charAt(0).toUpperCase() + name.slice(1);
    }

    options: [root.silent].concat(NotificationSettings.sounds
        .map(name => ({ value: name, label: root.titled(name) })))
    current: root.sound ?? null
}
