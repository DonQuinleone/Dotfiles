import QtQuick
import qs.services

Text {
    id: root

    visible: root.text !== ""
    wrapMode: Text.Wrap
    color: Theme.palette.fgDim ?? "white"
    font.family: Theme.fonts.mono ?? ""
    font.pixelSize: Theme.fontSizes.normal ?? 0
}
