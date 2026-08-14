import QtQuick
import qs.services

Rectangle {
    id: root

    property alias content: layout.data

    implicitWidth: layout.implicitWidth
        + (Theme.sizes.barPadding ?? 0) * 2
    implicitHeight: Theme.sizes.hitTarget ?? 0
    radius: Theme.radii.normal ?? 0
    color: Theme.palette.surface ?? "transparent"
    border.width: Theme.sizes.borderWidth ?? 0
    border.color: Theme.palette.border ?? "transparent"

    Row {
        id: layout

        anchors.centerIn: parent
        height: root.height
        spacing: Theme.spacing.tight ?? 0
    }
}
