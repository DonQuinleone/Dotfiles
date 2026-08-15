import QtQuick
import Quickshell.Hyprland
import qs.services

BarPill {
    id: root

    required property string monitorName

    readonly property string floatingGlyph: "󰆏"
    readonly property string unknownGlyph: ""

    readonly property var tiledGlyphs: ({
        "master": "󰕮",
        "monocle": "󰝤",
        "scrolling": "󰕫",
        "dwindle": "󰕰"
    })

    readonly property var monitor: Hyprland.monitors.values
        .find(candidate => candidate.name === root.monitorName) ?? null

    readonly property string workspaceName:
        root.monitor?.activeWorkspace?.name ?? ""

    readonly property string layoutName:
        WorkspaceSnapshot.layoutOf(root.monitor?.activeWorkspace)

    readonly property string glyph: {
        if (WorkspaceSnapshot.floatingOn(root.workspaceName)) {
            return root.floatingGlyph;
        }
        return root.tiledGlyphs[root.layoutName] ?? root.unknownGlyph;
    }

    visible: root.glyph !== root.unknownGlyph

    content: [
        PillText {
            text: root.glyph
            color: Theme.palette.fgDim ?? "white"
            font.pixelSize: Theme.sizes.iconNormal ?? 0
        }
    ]
}
