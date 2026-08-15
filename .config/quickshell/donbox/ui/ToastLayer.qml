import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.services

PanelWindow {
    id: root

    required property var modelData

    readonly property real widthFactor: 1.3
    readonly property int toastWidth:
        (Theme.sizes.menuWidth ?? 0) * root.widthFactor
    readonly property int edge: Theme.spacing.section ?? 0

    readonly property bool focused:
        Hyprland.focusedMonitor?.name === root.modelData.name

    screen: root.modelData
    visible: root.focused
    color: Qt.alpha(Theme.palette.bg ?? "black", 0)
    exclusionMode: ExclusionMode.Normal
    exclusiveZone: 0
    implicitWidth: root.toastWidth + root.edge
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "donbox-toasts"

    mask: Region {
        item: stack
    }

    anchors {
        top: true
        right: true
        bottom: true
    }

    margins {
        top: root.edge
        bottom: root.edge
    }

    Column {
        id: stack

        anchors.right: parent.right
        anchors.rightMargin: root.edge
        width: root.toastWidth

        Repeater {
            model: Notifications.toasts

            Toast {
                width: stack.width
            }
        }
    }
}
