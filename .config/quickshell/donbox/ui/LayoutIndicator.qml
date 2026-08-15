import QtQuick
import Quickshell.Hyprland
import qs.services

BarPill {
    id: root

    required property string monitorName

    readonly property var monitor: Hyprland.monitors.values
        .find(candidate => candidate.name === root.monitorName) ?? null

    readonly property string layoutName:
        WorkspaceSnapshot.layoutOf(root.monitor?.activeWorkspace)

    visible: root.layoutName !== ""

    content: [
        PillText {
            text: root.layoutName
            color: Theme.palette.fgDim ?? "white"
            font.pixelSize: Theme.fontSizes.small ?? 0
            font.capitalization: Font.AllUppercase
            font.letterSpacing: Theme.spacing.hair ?? 0
        }
    ]
}
