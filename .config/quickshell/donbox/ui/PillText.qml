import QtQuick
import qs.services

Text {
    height: parent?.height ?? 0
    verticalAlignment: Text.AlignVCenter
    color: Theme.palette.fg ?? "white"
    font.family: Theme.fonts.mono ?? ""
    font.pixelSize: Theme.fontSizes.normal ?? 0
    font.weight: Theme.fontWeights.medium ?? 0
    font.features: ({ "tnum": 1 })
}
