import QtQuick
import qs.services

BarPill {
    id: root

    readonly property bool silenced: NotificationStore.doNotDisturb
    readonly property int pending: NotificationStore.pending

    readonly property string glyph: {
        if (root.silenced) return "󰂛";
        if (root.pending > 0) return "󰂞";
        return "󰂚";
    }

    readonly property color tint: {
        if (root.silenced) return Theme.palette.warn ?? "white";
        if (root.pending > 0) return Theme.palette.accent ?? "white";
        return Theme.palette.fg ?? "white";
    }

    highlighted: Notifications.centreOpen

    content: [
        PillText {
            text: root.glyph
            color: root.tint
            font.pixelSize: Theme.sizes.iconNormal ?? 0
        },
        PillText {
            text: `${root.pending}`
            visible: root.pending > 0
            color: root.tint
        },
        PillText {
            text: "DND"
            visible: root.silenced
            color: root.tint
            font.pixelSize: Theme.fontSizes.small ?? 0
            font.letterSpacing: Theme.spacing.hair ?? 0
        }
    ]

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor

        onClicked: mouse => mouse.button === Qt.RightButton
            ? NotificationStore.toggleDoNotDisturb()
            : Notifications.toggleCentre()
    }
}
