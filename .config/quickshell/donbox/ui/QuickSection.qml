import QtQuick
import qs.services

Column {
    id: root

    required property string title

    default property alias body: holder.data

    spacing: Theme.spacing.tight ?? 0

    Text {
        text: root.title
        color: Theme.palette.fgDim ?? "white"
        font.family: Theme.fonts.ui ?? ""
        font.pixelSize: Theme.fontSizes.normal ?? 0
        font.weight: Theme.fontWeights.bold ?? 0
    }

    Column {
        id: holder

        width: parent.width
        spacing: Theme.spacing.tight ?? 0
    }
}
