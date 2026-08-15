import QtQuick
import qs.services

Text {
    elide: Text.ElideRight
    color: Theme.palette.fg ?? "white"
    font.family: Theme.fonts.ui ?? ""
    font.pixelSize: Theme.fontSizes.display ?? 0
    font.weight: Theme.fontWeights.bold ?? 0
}
