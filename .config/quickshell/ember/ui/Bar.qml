import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.services

PanelWindow {
    id: root

    required property var modelData

    readonly property string monitorName: root.modelData.name
    readonly property bool focused:
        Hyprland.focusedMonitor?.name === root.monitorName

    screen: root.modelData
    visible: BarVisibility.isVisible(root.monitorName)
    color: Qt.alpha(Theme.palette.bg ?? "black", 0)
    exclusionMode: ExclusionMode.Auto
    implicitHeight: Theme.sizes.barHeight ?? 0
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "ember-bar"

    anchors {
        top: true
        left: true
        right: true
    }

    onFocusedChanged: if (root.focused) flash.restart()

    Rectangle {
        anchors.fill: parent
        color: root.focused
            ? (Theme.palette.bgAlt ?? "black")
            : (Theme.palette.bg ?? "black")

        Behavior on color {
            ColorAnimation {
                duration: Theme.duration("normal")
                easing.type: Theme.easing("standard")
            }
        }
    }

    Rectangle {
        id: glow

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: Theme.sizes.focusGlow ?? 0
        opacity: 0

        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: Qt.alpha(Theme.palette.accent ?? "black", 0)
            }
            GradientStop {
                position: 1.0
                color: Theme.palette.accent ?? "transparent"
            }
        }
    }

    SequentialAnimation {
        id: flash

        NumberAnimation {
            target: glow
            property: "opacity"
            to: Theme.opacities.dim ?? 0
            duration: Theme.duration("quick")
            easing.type: Theme.easing("standard")
        }

        NumberAnimation {
            target: glow
            property: "opacity"
            to: 0
            duration: Theme.duration("flash")
            easing.type: Theme.easing("standard")
        }
    }

    Item {
        id: content

        anchors.fill: parent
        anchors.leftMargin: Theme.sizes.barPadding ?? 0
        anchors.rightMargin: Theme.sizes.barPadding ?? 0
        anchors.bottomMargin: Theme.sizes.focusEdge ?? 0
        opacity: root.focused
            ? (Theme.opacities.full ?? 1)
            : (Theme.opacities.dim ?? 1)

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.duration("normal")
                easing.type: Theme.easing("standard")
            }
        }

        Row {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing: Theme.spacing.normal ?? 0

            WorkspaceRow {
                monitorName: root.monitorName
            }

            LayoutIndicator {
                monitorName: root.monitorName
            }
        }

        ClockDisplay {
            anchors.centerIn: parent
        }

        Row {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: Theme.spacing.normal ?? 0

            ZoomIndicator {}

            TrayRow {}

            NotificationPill {}

            VitalsCluster {}
        }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: Theme.sizes.focusEdge ?? 0
        opacity: Theme.opacities.edge ?? 1
        color: root.focused
            ? (Theme.palette.accent ?? "transparent")
            : (Theme.palette.border ?? "transparent")

        Behavior on color {
            ColorAnimation {
                duration: Theme.duration("normal")
                easing.type: Theme.easing("standard")
            }
        }
    }
}
