import QtQuick
import qs.services

Row {
    id: root

    required property string glyph
    required property string caption
    required property string value

    spacing: Theme.spacing.tight ?? 0

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: root.glyph
        color: Theme.palette.accent ?? "white"
        font.family: Theme.fonts.mono ?? ""
        font.pixelSize: Theme.sizes.iconNormal ?? 0
    }

    Column {
        anchors.verticalCenter: parent.verticalCenter

        Text {
            text: root.caption
            color: Theme.palette.fgDim ?? "white"
            font.family: Theme.fonts.ui ?? ""
            font.pixelSize: Theme.fontSizes.small ?? 0
        }

        Text {
            text: root.value
            color: Theme.palette.fg ?? "white"
            font.family: Theme.fonts.mono ?? ""
            font.pixelSize: Theme.fontSizes.normal ?? 0
            font.weight: Theme.fontWeights.medium ?? 0
        }
    }
}
