import QtQuick
import qs.services

SettingsButton {
    id: root

    required property bool checked

    property string onWord: qsTr("On")
    property string offWord: qsTr("Off")

    readonly property string tick: "󰄬"
    readonly property string cross: "󰅖"

    label: root.checked ? root.onWord : root.offWord
    glyph: root.checked ? root.tick : root.cross
    selected: root.checked

    Keys.onLeftPressed: root.activated()
    Keys.onRightPressed: root.activated()
    Keys.onUpPressed: root.activated()
    Keys.onDownPressed: root.activated()
}
