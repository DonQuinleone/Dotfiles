import Quickshell.Hyprland
import qs.services

HyprlandFocusGrab {
    id: root

    required property var surface

    property bool shown: false

    signal dismissed

    windows: [root.surface, Panels.keySurface].filter(window => window)
    active: root.shown

    onCleared: root.dismissed()
}
