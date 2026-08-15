import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services

PanelWindow {
    id: root

    required property var modelData

    readonly property int holdMs: 40
    readonly property real peak: 0.55

    property bool firing: false

    function flash(): void {
        root.firing = true;
        hold.restart();
    }

    visible: root.firing || sheet.opacity > 0
    screen: root.modelData
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"

    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "donbox-flash"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    mask: Region {}

    Timer {
        id: hold

        interval: root.holdMs

        onTriggered: root.firing = false
    }

    Rectangle {
        id: sheet

        anchors.fill: parent
        color: Theme.palette.fg ?? "white"
        opacity: root.firing ? root.peak : 0

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.duration("quick")
                easing.type: Theme.easing("standard")
            }
        }
    }
}
