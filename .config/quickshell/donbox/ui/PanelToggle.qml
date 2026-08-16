import QtQuick
import qs.services

WheelArea {
    id: root

    required property var surface

    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor

    onClicked: Panels.toggle(root.surface.name)
}
