import QtQuick
import Quickshell
import Quickshell.Services.UPower
import qs.services

PopupWindow {
    id: root

    readonly property string timeFormat: "HH:mm"
    readonly property string dateFormat: "dddd d MMMM yyyy"

    readonly property real clockScale: 2.4
    readonly property int clockSize: Math.round(
        (Theme.fontSizes.display ?? 0) * root.clockScale)

    readonly property int percentScale: 100
    readonly property int gap: Theme.spacing.tight ?? 0
    readonly property int padding: Theme.sizes.popupPadding ?? 0
    readonly property int cardWidth: Metrics.surfaceWidth

    readonly property var device: UPower.displayDevice

    readonly property bool charging:
        root.device.state === UPowerDeviceState.Charging

    readonly property int chargePercent:
        Math.round(root.device.percentage * root.percentScale)

    readonly property real secondsRemaining: root.charging
        ? root.device.timeToFull
        : root.device.timeToEmpty

    readonly property string chargeSummary: {
        if (!root.device.ready || !root.device.isLaptopBattery)
            return "";
        const charge = `${root.chargePercent}%`;
        if (root.secondsRemaining <= 0) return charge;
        const remaining = SystemStats.formatDuration(
            root.secondsRemaining);
        const ending = root.charging ? "to full" : "left";
        return `${charge} · ${remaining} ${ending}`;
    }

    readonly property var figures: ({
        battery: root.chargeSummary,
        processor: `${SystemStats.cpuPercent}%`,
        temperature: SystemStats.temperatureAvailable
            ? `${Math.round(SystemStats.temperatureCelsius)} °C`
            : "",
        memory: `${SystemStats.formatBytes(
                SystemStats.memoryUsedBytes)} of `
            + SystemStats.formatBytes(SystemStats.memoryTotalBytes),
        disk: `${SystemStats.formatBytes(
                SystemStats.diskFreeBytes)} free of `
            + SystemStats.formatBytes(SystemStats.diskTotalBytes),
        uptime: SystemStats.formatDuration(
            SystemStats.uptimeSeconds),
        load: SystemStats.loadAverage,
        connection: Connectivity.label,
        address: SystemStats.addressIpv4,
        download: SystemStats.formatRate(
            SystemStats.downloadBytesPerSecond),
        upload: SystemStats.formatRate(
            SystemStats.uploadBytesPerSecond)
    })

    readonly property var sections: [
        {
            title: "Power",
            rows: [
                { label: "Battery", key: "battery" }
            ]
        },
        {
            title: "Machine",
            rows: [
                { label: "Processor", key: "processor" },
                { label: "Temperature", key: "temperature" },
                { label: "Memory", key: "memory" },
                { label: "Disk", key: "disk" },
                { label: "Uptime", key: "uptime" },
                { label: "Load", key: "load" }
            ]
        },
        {
            title: "Network",
            rows: [
                { label: "Connection", key: "connection" },
                { label: "Address", key: "address" },
                { label: "Down", key: "download" },
                { label: "Up", key: "upload" }
            ]
        }
    ]

    color: Qt.alpha(Theme.palette.bg ?? "black", 0)
    implicitWidth: frame.implicitWidth
    implicitHeight: frame.implicitHeight + root.gap
    visible: false

    PopoverGrab {
        surface: root
        shown: root.visible

        onDismissed: root.visible = false
    }

    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }

    Rectangle {
        id: frame

        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        implicitWidth: root.cardWidth + root.padding * 2
        implicitHeight: content.implicitHeight + root.padding * 2
        color: Theme.palette.bgAlt ?? "black"
        radius: Theme.radii.large ?? 0
        border.width: Theme.sizes.borderWidth ?? 0
        border.color: Theme.palette.border ?? "transparent"

        Column {
            id: content

            anchors.centerIn: parent
            width: root.cardWidth
            spacing: Theme.spacing.section ?? 0

            Column {
                width: parent.width
                spacing: Theme.spacing.hair ?? 0

                Text {
                    text: Qt.formatDateTime(clock.date,
                        root.timeFormat)
                    color: Theme.palette.fg ?? "white"
                    font.family: Theme.fonts.ui ?? ""
                    font.pixelSize: root.clockSize
                    font.weight: Theme.fontWeights.bold ?? 0
                    font.features: ({ "tnum": 1 })
                }

                Text {
                    text: Qt.formatDateTime(clock.date,
                        root.dateFormat)
                    color: Theme.palette.fgDim ?? "white"
                    font.family: Theme.fonts.ui ?? ""
                    font.pixelSize: Theme.fontSizes.large ?? 0
                    font.weight: Theme.fontWeights.medium ?? 0
                }
            }

            Repeater {
                model: root.sections

                GlanceSection {
                    required property var modelData

                    width: root.cardWidth
                    title: this.modelData.title
                    rows: this.modelData.rows
                    figures: root.figures
                }
            }
        }
    }
}
