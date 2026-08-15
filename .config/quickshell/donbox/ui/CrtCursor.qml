import QtQuick
import qs.services

// Ramped rather than switched: a hard blink on an OLED panel is
// a strobe, a slow fade is a heartbeat.
Rectangle {
    id: root

    readonly property real restOpacity: 0.32
    readonly property int pulseMs: 620

    readonly property bool pulsing: !Theme.reduceMotion

    color: Theme.palette.accent ?? "white"

    SequentialAnimation on opacity {
        running: root.pulsing
        loops: Animation.Infinite

        NumberAnimation {
            to: root.restOpacity
            duration: root.pulseMs
            easing.type: Easing.InOutQuad
        }

        NumberAnimation {
            to: 1
            duration: root.pulseMs
            easing.type: Easing.InOutQuad
        }
    }
}
