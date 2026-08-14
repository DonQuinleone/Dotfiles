import QtQuick
import qs.services

Item {
    id: root

    readonly property int maximumDots: 24
    readonly property real caretAspect: 0.16
    readonly property real edgeWeight: 2

    readonly property int glow: Theme.sizes.focusGlow ?? 0

    implicitWidth: Metrics.lockFieldWidth + root.glow * 2
    implicitHeight: Metrics.lockFieldHeight + root.glow * 2

    Rectangle {
        anchors.fill: parent
        radius: (Theme.radii.large ?? 0) + root.glow
        color: Theme.palette.accent ?? "white"
        opacity: Theme.opacities.edge ?? 0
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: root.glow
        radius: Theme.radii.large ?? 0
        color: Theme.palette.bg ?? "black"
        border.width: (Theme.sizes.borderWidth ?? 0) * root.edgeWeight
        border.color: Theme.palette.accent ?? "white"

        Row {
            anchors.centerIn: parent
            spacing: Theme.spacing.tight ?? 0

            Repeater {
                model: Lock.masked
                    ? Math.min(Lock.entry.length, root.maximumDots)
                    : 0

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: Metrics.lockDotSize
                    height: Metrics.lockDotSize
                    radius: Metrics.lockDotSize / 2
                    color: Theme.palette.fg ?? "white"
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                visible: !Lock.masked
                text: Lock.entry
                color: Theme.palette.fg ?? "white"
                font.family: Theme.fonts.mono ?? ""
                font.pixelSize: Metrics.lockEntrySize
            }

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: Math.max(1,
                    Math.round(Metrics.lockDotSize * root.caretAspect))
                height: Metrics.lockEntrySize
                color: Theme.palette.accent ?? "white"
            }
        }
    }
}
