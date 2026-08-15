import QtQuick
import Quickshell
import qs.services

Item {
    id: root

    implicitWidth: pills.implicitWidth
    implicitHeight: pills.implicitHeight

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onClicked: QuickSettings.toggle()
    }

    Connections {
        target: Panels

        function onRequested(name: string): void {
            glance.visible = name === "glance" && !glance.visible;
        }
    }

    Connections {
        target: glance

        function onVisibleChanged(): void {
            if (!glance.visible) Panels.noteClosed();
        }
    }

    GlancePopup {
        id: glance

        anchor.item: root
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom
    }

    Row {
        id: pills

        spacing: Theme.spacing.normal ?? 0

        NetworkIndicator {}

        BluetoothIndicator {
            highlighted: QuickSettings.shown
        }

        VolumeIndicator {}

        BatteryIndicator {}
    }
}
