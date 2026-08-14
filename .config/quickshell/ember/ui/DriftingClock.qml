import QtQuick
import Quickshell
import qs.services

Item {
    id: root

    readonly property string timeFormat: "HH:mm"

    readonly property real across: 0.5 + Screensaver.driftTravel
        * Math.cos(Screensaver.elapsed * Screensaver.driftRateAcross)
    readonly property real down: 0.5 + Screensaver.driftTravel
        * Math.sin(Screensaver.elapsed * Screensaver.driftRateDown)

    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }

    Text {
        x: (root.width - this.width) * root.across
        y: (root.height - this.height) * root.down
        text: Qt.formatDateTime(clock.date, root.timeFormat)
        color: Theme.palette.fgDim ?? "white"
        opacity: Theme.opacities.dim ?? 1
        font.family: Theme.fonts.ui ?? ""
        font.pixelSize: Metrics.screensaverClockSize
        font.weight: Theme.fontWeights.medium ?? 0
        font.features: ({ "tnum": 1 })
    }
}
