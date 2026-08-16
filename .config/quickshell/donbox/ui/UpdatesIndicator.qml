import QtQuick
import Quickshell
import qs.services

BarPill {
    id: root

    readonly property var updater: [Preferences.donbox, "update"]

    visible: Updates.offered

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onClicked: Quickshell.execDetached(root.updater)
    }

    content: [
        PillText {
            text: Updates.glyph
            color: Theme.palette.warn ?? "white"
            font.pixelSize: Theme.sizes.iconNormal ?? 0
        },
        PillText {
            text: Updates.countText
            color: Theme.palette.warn ?? "white"
        }
    ]
}
