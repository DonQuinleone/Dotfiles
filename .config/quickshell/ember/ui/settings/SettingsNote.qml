import QtQuick
import qs.services

Text {
    id: root

    property bool warning: false

    visible: root.text !== ""
    wrapMode: Text.WordWrap
    color: root.warning
        ? (Theme.palette.warn ?? "white")
        : (Theme.palette.fgDim ?? "white")
    font.family: Theme.fonts.ui ?? ""
    font.pixelSize: Theme.fontSizes.normal ?? 0
}
