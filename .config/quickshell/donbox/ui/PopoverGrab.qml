import QtQuick
import Quickshell.Hyprland
import qs.services

// The compositor refuses a grab for an unmapped surface,
// and refuses it silently, which reads as a pane that
// will not close.
HyprlandFocusGrab {
    id: root

    required property var surface

    property bool when: true

    property var owner: null

    readonly property bool shown: root.when
        && root.surface.visible
        && root.surface.backingWindowVisible

    signal dismissed

    windows: root.owner
        ? [root.surface, root.owner]
        : [root.surface]

    onShownChanged: root.active = root.shown

    onActiveChanged: Panels.grabActive = root.active

    onCleared: root.dismissed()
}
