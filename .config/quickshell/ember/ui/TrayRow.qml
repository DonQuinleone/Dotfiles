import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs.services

Row {
    id: root

    visible: SystemTray.items.values.length > 0
    spacing: Theme.spacing.tight ?? 0

    Repeater {
        model: SystemTray.items

        Rectangle {
            id: slot

            required property SystemTrayItem modelData

            width: Theme.sizes.hitTarget ?? 0
            height: Theme.sizes.hitTarget ?? 0
            radius: Theme.radii.normal ?? 0
            color: area.containsMouse
                ? (Theme.palette.surface ?? "transparent")
                : Qt.alpha(Theme.palette.surface ?? "black", 0)

            IconImage {
                anchors.centerIn: parent
                implicitSize: Theme.sizes.trayIcon ?? 0
                source: slot.modelData.icon
                asynchronous: true
            }

            MouseArea {
                id: area

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton

                onClicked: mouse => {
                    if (mouse.button === Qt.RightButton) {
                        menu.visible = !menu.visible;
                        return;
                    }
                    slot.modelData.activate();
                }
            }

            TrayMenuPopup {
                id: menu

                handle: slot.modelData.menu
                anchor.item: slot
                anchor.edges: Edges.Bottom
                anchor.gravity: Edges.Bottom
            }
        }
    }
}
