import QtQuick
import qs.services

SettingsRow {
    id: root

    required property var unit

    label: root.unit.name
    hint: qsTr("%1, %2").arg(root.unit.id)
        .arg(Autostart.stateWord(root.unit.state))

    AutostartCommand {
        width: parent.width
        text: root.unit.command
    }
}
