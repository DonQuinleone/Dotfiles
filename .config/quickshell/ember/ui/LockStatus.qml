import QtQuick
import Quickshell.Services.Mpris
import Quickshell.Services.UPower
import qs.services

Row {
    id: root

    readonly property string mediaGlyph: "󰎈"

    readonly property var device: UPower.displayDevice
    readonly property bool charging:
        root.device.state === UPowerDeviceState.Charging
        || root.device.state === UPowerDeviceState.FullyCharged
    readonly property int percent:
        Math.round(root.device.percentage * 100)

    readonly property real mediaShare: 0.5

    readonly property var player: (Mpris.players?.values ?? [])
        .find(candidate => candidate.isPlaying) ?? null

    readonly property string playing: root.player
        ? [root.player.trackTitle, root.player.trackArtist]
            .filter(part => !!part).join("  ·  ")
        : ""

    spacing: Theme.spacing.section ?? 0

    Row {
        spacing: Theme.spacing.tight ?? 0
        visible: root.device.ready && root.device.isLaptopBattery

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.charging
                ? Battery.chargingGlyph
                : Battery.glyphFor(root.percent)
            color: root.charging
                ? (Theme.palette.good ?? "white")
                : Battery.tintFor(root.percent)
            font.family: Theme.fonts.mono ?? ""
            font.pixelSize: Metrics.lockEntrySize
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: `${root.percent}%`
            color: Theme.palette.fgDim ?? "white"
            font.family: Theme.fonts.ui ?? ""
            font.pixelSize: Metrics.lockEntrySize
            font.features: ({ "tnum": 1 })
        }
    }

    Row {
        spacing: Theme.spacing.tight ?? 0
        visible: root.playing !== ""

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.mediaGlyph
            color: Theme.palette.accent ?? "white"
            font.family: Theme.fonts.mono ?? ""
            font.pixelSize: Metrics.lockEntrySize
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            width: Math.min(this.implicitWidth,
                Metrics.lockFieldWidth * root.mediaShare)
            text: root.playing
            color: Theme.palette.fgDim ?? "white"
            elide: Text.ElideRight
            font.family: Theme.fonts.ui ?? ""
            font.pixelSize: Metrics.lockEntrySize
        }
    }
}
