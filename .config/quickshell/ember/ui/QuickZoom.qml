import QtQuick
import qs.services

Item {
    id: root

    implicitHeight: Theme.sizes.hitTarget ?? 0

    Text {
        anchors.left: parent.left
        anchors.right: buttons.left
        anchors.rightMargin: Theme.spacing.tight ?? 0
        anchors.verticalCenter: parent.verticalCenter
        text: `${CursorZoom.percent}%`
        color: CursorZoom.magnified
            ? (Theme.palette.accent ?? "white")
            : (Theme.palette.fg ?? "white")
        font.family: Theme.fonts.mono ?? ""
        font.pixelSize: Theme.fontSizes.display ?? 0
        font.weight: Theme.fontWeights.bold ?? 0
        font.features: ({ "tnum": 1 })
    }

    Row {
        id: buttons

        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.spacing.tight ?? 0

        QuickChip {
            label: "Zoom out"

            onActivated: CursorZoom.nudge(-CursorZoom.step)
        }

        QuickChip {
            label: "Zoom in"

            onActivated: CursorZoom.nudge(CursorZoom.step)
        }

        QuickChip {
            label: "Reset"

            onActivated: CursorZoom.reset()
        }
    }
}
