import QtQuick
import qs.services

Column {
    id: root

    required property var device

    readonly property bool reports: BluetoothRadio.reports(root.device)
    readonly property int percent: BluetoothRadio.percentOf(root.device)

    readonly property int gap: Theme.spacing.tight ?? 0

    spacing: root.gap

    Item {
        width: parent.width
        height: Math.max(name.implicitHeight, status.implicitHeight)

        Text {
            id: name

            anchors.left: parent.left
            anchors.right: status.left
            anchors.rightMargin: root.gap
            elide: Text.ElideRight
            text: root.device.name
            color: Theme.palette.fg ?? "white"
            font.family: Theme.fonts.ui ?? ""
            font.pixelSize: Theme.fontSizes.normal ?? 0
            font.weight: Theme.fontWeights.medium ?? 0
        }

        Row {
            id: status

            anchors.right: parent.right
            anchors.verticalCenter: name.verticalCenter
            spacing: root.gap

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: BluetoothRadio.statusOf(root.device)
                color: root.device.connected
                    ? (Theme.palette.good ?? "white")
                    : (Theme.palette.fgDim ?? "white")
                font.family: Theme.fonts.ui ?? ""
                font.pixelSize: Theme.fontSizes.small ?? 0
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                visible: root.reports
                text: `${Battery.glyphFor(root.percent)} `
                    + `${root.percent}%`
                color: Battery.tintFor(root.percent)
                font.family: Theme.fonts.mono ?? ""
                font.pixelSize: Theme.fontSizes.normal ?? 0
                font.weight: Theme.fontWeights.medium ?? 0
            }
        }
    }

    Flow {
        width: parent.width
        spacing: root.gap

        QuickChip {
            label: root.device.connected ? "Disconnect" : "Connect"
            selected: root.device.connected

            onActivated: BluetoothRadio.toggleLink(root.device)
        }

        QuickChip {
            label: root.device.trusted ? "Untrust" : "Trust"
            selected: root.device.trusted

            onActivated: BluetoothRadio.toggleTrust(root.device)
        }

        QuickChip {
            label: "Forget"

            onActivated: BluetoothRadio.forget(root.device)
        }
    }
}
