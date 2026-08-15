import QtQuick
import qs.services

SettingsRow {
    id: root

    required property var device

    readonly property bool paired: BluetoothRadio.isPaired(root.device)
    readonly property bool reports: BluetoothRadio.reports(root.device)
    readonly property int percent: BluetoothRadio.percentOf(root.device)

    readonly property var pairedActions: [
        {
            label: root.device.connected
                ? qsTr("Disconnect")
                : qsTr("Connect"),
            glyph: root.device.connected ? "󰂲" : "󰂱",
            selected: root.device.connected,
            act: () => BluetoothRadio.toggleLink(root.device)
        },
        {
            label: root.device.trusted
                ? qsTr("Stop trusting")
                : qsTr("Trust"),
            glyph: "󰒃",
            selected: root.device.trusted,
            act: () => BluetoothRadio.toggleTrust(root.device)
        },
        {
            label: qsTr("Forget"),
            glyph: "󰺝",
            selected: false,
            act: () => BluetoothRadio.forget(root.device)
        }
    ]

    readonly property var unpairedActions: [
        {
            label: root.device.pairing
                ? qsTr("Stop pairing")
                : qsTr("Pair"),
            glyph: "󰌹",
            selected: root.device.pairing,
            act: () => BluetoothRadio.togglePairing(root.device)
        }
    ]

    readonly property var actions: root.paired
        ? root.pairedActions
        : root.unpairedActions

    label: root.device.name
    hint: root.device.name === root.device.address
        ? ""
        : root.device.address

    Row {
        spacing: Theme.spacing.tight ?? 0

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: BluetoothRadio.statusOf(root.device)
            color: root.device.connected
                ? (Theme.palette.good ?? "white")
                : (Theme.palette.fgDim ?? "white")
            font.family: Theme.fonts.ui ?? ""
            font.pixelSize: Theme.fontSizes.normal ?? 0
            font.weight: Theme.fontWeights.medium ?? 0
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

    Flow {
        width: parent.width
        spacing: Theme.spacing.tight ?? 0

        Repeater {
            model: root.actions

            SettingsButton {
                required property var modelData

                label: this.modelData.label
                glyph: this.modelData.glyph
                selected: this.modelData.selected

                onActivated: this.modelData.act()
            }
        }
    }
}
