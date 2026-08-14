import QtQuick
import Quickshell
import qs.services

PopupWindow {
    id: root

    required property QsMenuHandle handle

    readonly property int gap: Theme.spacing.tight ?? 0

    color: Qt.alpha(Theme.palette.bg ?? "black", 0)
    implicitWidth: Theme.sizes.menuWidth ?? 0
    implicitHeight: frame.implicitHeight + root.gap
    visible: false

    QsMenuOpener {
        id: opener

        menu: root.handle
    }

    Rectangle {
        id: frame

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        implicitHeight: entries.implicitHeight
            + (Theme.spacing.tight ?? 0) * 2
        color: Theme.palette.bgAlt ?? "black"
        radius: Theme.radii.large ?? 0
        border.width: Theme.sizes.borderWidth ?? 0
        border.color: Theme.palette.border ?? "transparent"
        clip: true

        Column {
            id: entries

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: Theme.spacing.tight ?? 0

            Repeater {
                model: opener.children

                TrayMenuEntry {
                    required property QsMenuEntry modelData

                    entry: this.modelData

                    onDismissed: root.visible = false
                }
            }
        }
    }
}
