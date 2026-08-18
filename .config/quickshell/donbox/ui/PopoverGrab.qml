import QtQuick
import Quickshell.Hyprland
import qs.services

// The compositor refuses a grab for a surface it has not
// mapped, and a refused grab is silent: it simply never
// reports a click landing elsewhere, which reads as a pane
// that will not close. Arming therefore waits for the backing
// window to actually exist, the earliest moment a grab can be
// granted, rather than racing the map with a timer.
HyprlandFocusGrab {
    id: root

    required property var surface

    // The caller's own idea of being on show, for surfaces that
    // stay mapped through their closing motion.
    property bool when: true

    // A second window trusted alongside the surface, the bar
    // above all, so a click on another pill switches panes
    // rather than being spent on dismissing the first one.
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
