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
    readonly property int edge: Theme.spacing.normal ?? 0

    readonly property bool focused:
        Hyprland.focusedMonitor?.name === root.modelData.name

    screen: root.modelData
    visible: root.focused && Notifications.toasts.length > 0
    color: Qt.alpha(Theme.palette.bg ?? "black", 0)
    exclusionMode: ExclusionMode.Normal
    exclusiveZone: 0
    implicitWidth: root.toastWidth
    implicitHeight: stack.implicitHeight
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "ember-toasts"

    anchors {
        top: true
        right: true
    }

    margins {
        top: root.edge
        right: root.edge
    }

    Column {
        id: stack

        width: root.toastWidth
        spacing: Theme.spacing.tight ?? 0

        Repeater {
            model: Notifications.toasts

            Toast {
                width: stack.width
            }
        }
    }
}
