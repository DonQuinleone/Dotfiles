import Quickshell.Hyprland

HyprlandFocusGrab {
    id: root

    required property var surface

    property bool shown: false

    signal dismissed

    windows: [root.surface]
    active: root.shown

    onCleared: root.dismissed()
}
