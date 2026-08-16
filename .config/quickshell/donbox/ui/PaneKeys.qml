import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services

// A pane is a PopupWindow, and a PopupWindow is never given the
// keyboard, so Escape has nowhere to land. This is the surface
// that holds it: one layer, no size and nothing drawn, alive
// only while a pane is open. PopoverGrab keeps it inside the
// grab, or taking the keyboard would read as focus leaving the
// pane and close it on the way in.
PanelWindow {
    id: root

    visible: Panels.open !== Panels.none
    focusable: true
    color: "transparent"
    implicitWidth: 1
    implicitHeight: 1
    exclusiveZone: 0

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "donbox-pane-keys"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    Component.onCompleted: Panels.keySurface = root

    Item {
        anchors.fill: parent
        focus: true

        Keys.onEscapePressed: Panels.close()
    }
}
