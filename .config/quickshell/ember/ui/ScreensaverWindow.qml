import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services

PanelWindow {
    id: root

    required property var modelData

    readonly property int armingMs: 800
    readonly property int fadeInMs: 1500

    property bool armed: false

    visible: Screensaver.active
    screen: root.modelData
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "ember-screensaver"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    // The pointer is already under the surface when it appears,
    // so the first enter event is not the user coming back.
    onVisibleChanged: {
        root.armed = false;
        if (root.visible) arming.restart();
    }

    function dismiss(): void {
        if (!root.armed) return;
        Screensaver.stop();
    }

    Timer {
        id: arming

        interval: root.armingMs

        onTriggered: root.armed = true
    }

    Item {
        id: canvas

        anchors.fill: parent
        focus: true
        opacity: root.visible ? 1 : 0

        Keys.onPressed: event => {
            event.accepted = true;
            root.dismiss();
        }

        Behavior on opacity {
            NumberAnimation {
                duration: root.fadeInMs
                easing.type: Theme.easing("standard")
            }
        }

        LavaLamp {
            anchors.fill: parent
        }

        DriftingClock {
            anchors.fill: parent
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.AllButtons

            onPositionChanged: root.dismiss()
            onPressed: root.dismiss()
            onWheel: root.dismiss()
        }
    }
}
