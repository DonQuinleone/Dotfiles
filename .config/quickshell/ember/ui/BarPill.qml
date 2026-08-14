import QtQuick
import qs.services

Rectangle {
    id: root

    property alias content: layout.data
    property bool highlighted: false

    implicitWidth: layout.implicitWidth
        + (Theme.sizes.barPadding ?? 0) * 2
    implicitHeight: Theme.sizes.hitTarget ?? 0
    radius: Theme.radii.normal ?? 0
    color: Theme.palette.surface ?? "transparent"
    border.width: Theme.sizes.borderWidth ?? 0
    border.color: root.highlighted
        ? (Theme.palette.accent ?? "transparent")
        : (Theme.palette.border ?? "transparent")

    Behavior on border.color {
        ColorAnimation {
            duration: Theme.duration("quick")
            easing.type: Theme.easing("standard")
        }
    }

    Row {
        id: layout

        anchors.centerIn: parent
        height: root.height
        spacing: Theme.spacing.tight ?? 0
    }
}
