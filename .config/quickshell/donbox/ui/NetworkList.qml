import QtQuick
import qs.services

Column {
    id: root

    property alias model: rows.model
    property alias delegate: rows.delegate

    property int total: 0

    readonly property int shown: rows.count
    readonly property int hidden: Math.max(0, root.total - root.shown)

    readonly property string vacantText: "Nothing to show"

    spacing: Theme.spacing.hair ?? 0

    Text {
        width: parent.width
        visible: root.shown === 0
        text: root.vacantText
        color: Theme.palette.fgDim ?? "white"
        font.family: Theme.fonts.ui ?? ""
        font.pixelSize: Theme.fontSizes.small ?? 0
    }

    Repeater {
        id: rows
    }

    Text {
        width: parent.width
        visible: root.hidden > 0
        text: `and ${root.hidden} more`
        color: Theme.palette.fgDim ?? "white"
        font.family: Theme.fonts.ui ?? ""
        font.pixelSize: Theme.fontSizes.small ?? 0
    }
}
