import QtQuick
import Quickshell.Hyprland
import qs.services

// The compositor refuses a grab for a surface it has not mapped
// yet, and a pane arms its grab in the same pass that makes it
// visible, so arming waits until the surface exists. A refused
// grab is silent: it simply never reports a click landing
// elsewhere, which reads as a pane that will not close.
HyprlandFocusGrab {
    id: root

    required property var surface

    property bool shown: false

    // A property rather than a child, since a focus grab is a
    // plain object and has nowhere to put one.
    property Timer arm: Timer {
        interval: 1

        onTriggered: root.active = root.shown
    }

    signal dismissed

    windows: [root.surface]

    onActiveChanged: Panels.grabActive = root.active

    onShownChanged: {
        if (!root.shown) {
            root.arm.stop();
            root.active = false;
            return;
        }
        root.arm.restart();
    }

    onCleared: root.dismissed()
}
