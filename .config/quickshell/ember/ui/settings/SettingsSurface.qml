import QtQuick
import qs.services

Rectangle {
    id: root

    property bool focused: false
    property bool highlighted: false
    property bool hovered: false

    readonly property int focusBorderFactor: 2

    readonly property color ink: root.highlighted
        ? Theme.onAccent
        : (Theme.palette.fg ?? "white")

    implicitHeight: Metrics.rowHeight
    radius: Theme.radii.normal ?? 0
    color: root.highlighted
        ? (Theme.palette.accent ?? "transparent")
        : (Theme.palette.surface ?? "transparent")
    border.width: (Theme.sizes.borderWidth ?? 0)
        * (root.focused ? root.focusBorderFactor : 1)
    border.color: root.focused
        ? (Theme.palette.fg ?? "transparent")
        : (root.hovered
            ? (Theme.palette.accentSoft ?? "transparent")
            : (Theme.palette.border ?? "transparent"))

    Behavior on color {
        ColorAnimation {
            duration: Theme.duration("quick")
            easing.type: Theme.easing("standard")
        }
    }
}
