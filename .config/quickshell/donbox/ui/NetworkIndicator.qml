import QtQuick
import Quickshell
import qs.services

BarPill {
    id: root

    readonly property real labelWidthFactor: 0.45
    readonly property int labelCeiling:
        (Theme.sizes.menuWidth ?? 0) * root.labelWidthFactor

    visible: Connectivity.available
    highlighted: panel.visible

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onClicked: Panels.toggle("network")
    }

    Connections {
        target: Panels

        function onRequested(name: string): void {
            panel.visible = name === "network" && !panel.visible;
        }
    }

    Connections {
        target: panel

        function onVisibleChanged(): void {
            if (!panel.visible) Panels.noteClosed();
        }
    }

    NetworkPanel {
        id: panel

        anchor.item: root
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom
    }

    content: [
        PillText {
            text: Connectivity.glyph
            color: Connectivity.tint
            font.pixelSize: Theme.sizes.iconNormal ?? 0
        },
        PillText {
            width: Math.min(this.implicitWidth, root.labelCeiling)
            elide: Text.ElideRight
            text: Connectivity.label
            color: Connectivity.tint
        },
        PillText {
            text: Connectivity.detail
            visible: Connectivity.detail !== ""
            color: Theme.palette.fgDim ?? "white"
            font.pixelSize: Theme.fontSizes.small ?? 0
        }
    ]
}
