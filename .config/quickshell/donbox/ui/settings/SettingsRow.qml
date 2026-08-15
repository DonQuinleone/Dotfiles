import QtQuick
import qs.services

Column {
    id: root

    default property alias content: holder.data

    required property string label

    property string hint: ""

    spacing: Theme.spacing.tight ?? 0

    Text {
        width: parent.width
        wrapMode: Text.WordWrap
        text: root.label
        color: Theme.palette.fg ?? "white"
        font.family: Theme.fonts.ui ?? ""
        font.pixelSize: Theme.fontSizes.large ?? 0
        font.weight: Theme.fontWeights.medium ?? 0
    }

    Text {
        width: parent.width
        visible: root.hint !== ""
        wrapMode: Text.WordWrap
        text: root.hint
        color: Theme.palette.fgDim ?? "white"
        font.family: Theme.fonts.ui ?? ""
        font.pixelSize: Theme.fontSizes.normal ?? 0
    }

    Column {
        id: holder

        width: parent.width
        spacing: Theme.spacing.tight ?? 0
    }
}
