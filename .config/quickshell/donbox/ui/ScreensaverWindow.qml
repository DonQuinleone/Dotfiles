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
    WlrLayershell.namespace: "donbox-screensaver"
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

        readonly property var saverScenes: ({
            lava: lavaScene,
            windmill: windmillScene,
            rain: rainScene
        })

        anchors.fill: parent
        focus: true
        opacity: root.visible ? 1 : 0

        Component {
            id: lavaScene

            LavaLamp {}
        }

        Component {
            id: windmillScene

            WindmillSaver {}
        }

        Component {
            id: rainScene

            CodeRain {}
        }

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

        Loader {
            anchors.fill: parent
            active: Screensaver.active
            sourceComponent: canvas.saverScenes[Screensaver.saver]
                ?? lavaScene
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
