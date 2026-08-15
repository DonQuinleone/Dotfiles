import QtQuick
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

    Row {
        id: pills

        spacing: Theme.spacing.normal ?? 0

        NetworkIndicator {
            highlighted: QuickSettings.shown
        }

        BluetoothIndicator {
            highlighted: QuickSettings.shown
        }

        VolumeIndicator {
            highlighted: QuickSettings.shown
        }

        BatteryIndicator {}
    }
}
