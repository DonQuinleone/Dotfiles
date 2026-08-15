import QtQuick
import qs.services

Column {
    id: root

    readonly property string hint:
        "Scan with a phone camera to join this network."
    readonly property string drawingText: "Drawing the code"

    spacing: Theme.spacing.tight ?? 0

    QuickChip {
        label: NetworkQr.shown ? "Hide code" : "Show code"
        selected: NetworkQr.shown

        onActivated: NetworkQr.shown = !NetworkQr.shown
    }

    Text {
        width: parent.width
        visible: NetworkQr.shown && NetworkQr.drawing
        text: root.drawingText
        color: Theme.palette.fgDim ?? "white"
        font.family: Theme.fonts.ui ?? ""
        font.pixelSize: Theme.fontSizes.small ?? 0
    }

    Text {
        width: parent.width
        wrapMode: Text.WordWrap
        visible: NetworkQr.shown && NetworkQr.trouble !== ""
        text: NetworkQr.trouble
        color: Theme.palette.warn ?? "white"
        font.family: Theme.fonts.ui ?? ""
        font.pixelSize: Theme.fontSizes.small ?? 0
    }

    Item {
        width: parent.width
        visible: NetworkQr.shown && NetworkQr.drawn
        implicitHeight: this.visible ? symbol.implicitHeight : 0

        Image {
            id: symbol

            anchors.horizontalCenter: parent.horizontalCenter
            cache: false
            fillMode: Image.PreserveAspectFit
            source: NetworkQr.drawing ? "" : NetworkQr.imageSource
        }
    }

    Text {
        width: parent.width
        wrapMode: Text.WordWrap
        visible: NetworkQr.shown && NetworkQr.drawn
        text: root.hint
        color: Theme.palette.fgDim ?? "white"
        font.family: Theme.fonts.ui ?? ""
        font.pixelSize: Theme.fontSizes.small ?? 0
    }
}
