import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.services

Row {
    id: root

    required property string monitorName

    readonly property var workspaces: Hyprland.workspaces.values
        .filter(workspace => workspace.id > 0
            && workspace.monitor?.name === root.monitorName)
        .sort((left, right) => left.id - right.id)

    readonly property var tones: ({
        active: {
            fill: Theme.palette.accent,
            edge: Theme.palette.accent,
            text: Theme.palette.bg
        },
        occupied: {
            fill: Theme.palette.surface,
            edge: Theme.palette.accentSoft,
            text: Theme.palette.fg
        },
        empty: {
            fill: Qt.alpha(Theme.palette.surface ?? "black", 0),
            edge: Theme.palette.border,
            text: Theme.palette.fgDim
        }
    })

    spacing: Theme.spacing.tight ?? 0

    Repeater {
        model: root.workspaces

        Rectangle {
            id: chip

            required property var modelData

            readonly property bool active: chip.modelData.active
            readonly property bool occupied:
                chip.modelData.toplevels.values.length > 0

            readonly property string tone: {
                if (chip.active) return "active";
                if (chip.occupied) return "occupied";
                return "empty";
            }

            readonly property var look: root.tones[chip.tone]

            width: Math.max(Theme.sizes.hitTarget ?? 0,
                number.implicitWidth + (Theme.spacing.normal ?? 0) * 2)
            height: Theme.sizes.hitTarget ?? 0
            radius: Theme.radii.normal ?? 0
            color: chip.look.fill
            border.width: chip.active
                ? 0 : (Theme.sizes.borderWidth ?? 0)
            border.color: chip.look.edge

            Behavior on color {
                ColorAnimation {
                    duration: Theme.duration("quick")
                    easing.type: Theme.easing("standard")
                }
            }

            Text {
                id: number

                anchors.centerIn: parent
                text: chip.modelData.id
                color: chip.look.text
                font.family: Theme.fonts.mono ?? ""
                font.pixelSize: Theme.fontSizes.large ?? 0
                font.weight: chip.active
                    ? (Theme.fontWeights.bold ?? 0)
                    : (Theme.fontWeights.medium ?? 0)
                font.features: ({ "tnum": 1 })
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor

                onClicked: chip.modelData.activate()
            }
        }
    }
}
