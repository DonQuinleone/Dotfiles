import QtQuick
import qs.services

BarPill {
    id: root

    readonly property string restingGlyph: "󰂚"
    readonly property string ringingGlyph: "󰂞"
    readonly property string silentGlyph: "󰂛"

    readonly property bool silenced: NotificationStore.doNotDisturb
    readonly property int pending: NotificationStore.pending
    readonly property int unseen: NotificationStore.unseen

    readonly property string glyph: {
        if (root.silenced) return root.silentGlyph;
        if (root.unseen > 0) return root.ringingGlyph;
        return root.restingGlyph;
    }

    readonly property color tint: {
        if (root.silenced) return Theme.palette.warn ?? "white";
        if (root.unseen > 0) return Theme.palette.accent ?? "white";
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
