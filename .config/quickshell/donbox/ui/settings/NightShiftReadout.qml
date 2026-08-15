import QtQuick
import qs.services

Column {
    id: root

    spacing: Theme.spacing.hair ?? 0

    Text {
        width: parent.width
        elide: Text.ElideRight
        text: NightShift.temperatureText
        color: NightShift.active
            ? (Theme.palette.accent ?? "white")
            : (Theme.palette.fg ?? "white")
        font.family: Theme.fonts.mono ?? ""
        font.pixelSize: Theme.fontSizes.display ?? 0
        font.weight: Theme.fontWeights.bold ?? 0
        font.features: ({ "tnum": 1 })
    }

    SettingsNote {
        width: parent.width
        text: NightShift.phaseText
    }
}
