import QtQuick
import qs.services

WheelArea {
    id: root

    required property string name
    required property var surface

    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor

    onClicked: Panels.toggle(root.name)

    Connections {
        target: Panels

        function onRequested(name: string): void {
            root.surface.visible =
                name === root.name && !root.surface.visible;
        }
    }

    Connections {
        target: root.surface

        function onVisibleChanged(): void {
            if (!root.surface.visible) Panels.noteClosed();
        }
    }
}
