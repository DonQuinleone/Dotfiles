import QtQuick
import Quickshell.Services.UPower
import qs.services

Row {
    id: root

    readonly property var device: UPower.displayDevice
    readonly property bool charging:
        root.device.state === UPowerDeviceState.Charging
        || root.device.state === UPowerDeviceState.FullyCharged
    readonly property int percent:
        Math.round(root.device.percentage * 100)

    readonly property string words: root.charging
        ? qsTr("%1% and charging").arg(root.percent)
        : qsTr("%1% left").arg(root.percent)

    visible: root.device.ready && root.device.isLaptopBattery
    spacing: Theme.spacing.tight ?? 0

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: root.charging
            ? Battery.chargingGlyph
            : Battery.glyphFor(root.percent)
        color: root.charging
            ? (Theme.palette.good ?? "white")
            : Battery.tintFor(root.percent)
        font.family: Theme.fonts.mono ?? ""
        font.pixelSize: Theme.sizes.iconNormal ?? 0
    }

    SettingsNote {
        anchors.verticalCenter: parent.verticalCenter
        text: root.words
    }
}
