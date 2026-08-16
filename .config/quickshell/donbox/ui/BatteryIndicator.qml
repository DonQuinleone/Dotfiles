import QtQuick
import Quickshell
import Quickshell.Services.UPower
import qs.services

BarPill {
    id: root

    readonly property var device: UPower.displayDevice
    readonly property bool charging:
        root.device.state === UPowerDeviceState.Charging
        || root.device.state === UPowerDeviceState.FullyCharged
    readonly property int percent:
        Math.round(root.device.percentage * 100)

    readonly property string glyph: root.charging
        ? Battery.chargingGlyph
        : Battery.glyphFor(root.percent)

    readonly property color tint: root.charging
        ? (Theme.palette.good ?? "white")
        : Battery.tintFor(root.percent)

    visible: root.device.ready && root.device.isLaptopBattery
    highlighted: panel.visible

    PanelToggle {
        surface: panel
    }

    PowerPanel {
        id: panel

        name: "power"

        anchor.item: root
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom
    }

    content: [
        PillText {
            text: root.glyph
            color: root.tint
            font.pixelSize: Theme.sizes.iconNormal ?? 0
        },
        PillText {
            text: `${root.percent}%`
            color: root.tint
        }
    ]
}
