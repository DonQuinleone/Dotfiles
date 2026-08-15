pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property int pollIntervalMs: 2000
    readonly property int slowPollIntervalMs: 30000

    readonly property string statPath: "/proc/stat"
    readonly property string memoryPath: "/proc/meminfo"
    readonly property string uptimePath: "/proc/uptime"
    readonly property string loadPath: "/proc/loadavg"
    readonly property string routePath: "/proc/net/route"
    readonly property string trafficPath: "/proc/net/dev"

    readonly property string diskMount: "/"
    readonly property string hwmonNames: "/sys/class/hwmon/*/name"
    readonly property string temperatureSensor: "temp1_input"

    readonly property var temperatureDrivers:
        ["coretemp", "k10temp", "zenpower"]

    readonly property string sensorProbe:
        `grep -lE '^(${root.temperatureDrivers.join("|")})$'`
        + ` ${root.hwmonNames}`

    readonly property string memoryTotalKey: "MemTotal"
    readonly property string memoryAvailableKey: "MemAvailable"
    readonly property string defaultRouteHex: "00000000"

    readonly property int percentScale: 100
    readonly property int bytesPerKibibyte: 1024
    readonly property int millidegreesPerDegree: 1000
    readonly property int millisecondsPerSecond: 1000
    readonly property int secondsPerMinute: 60
    readonly property int minutesPerHour: 60
    readonly property int hoursPerDay: 24
    readonly property int minuteDigits: 2

    readonly property int cpuIdleField: 3
    readonly property int cpuIowaitField: 4
    readonly property int loadFigureCount: 3
    readonly property int routeInterfaceField: 0
    readonly property int routeDestinationField: 1
    readonly property int routeMaskField: 7
    readonly property int receivedBytesField: 0
    readonly property int transmittedBytesField: 8
    readonly property int addressInterfaceField: 1
    readonly property int addressValueField: 3
    readonly property int diskSizeField: 0
    readonly property int diskAvailableField: 1

    readonly property var byteUnits:
        ["B", "KiB", "MiB", "GiB", "TiB"]
    readonly property int byteFractionDigits: 1

    property int cpuPercent: 0
    property real memoryUsedBytes: 0
    property real memoryTotalBytes: 0
    property real diskFreeBytes: 0
    property real diskTotalBytes: 0
    property real uptimeSeconds: 0
    property real temperatureCelsius: 0
    property string temperaturePath: ""
    property string interfaceName: ""
    property string addressIpv4: ""
    property real downloadBytesPerSecond: 0
    property real uploadBytesPerSecond: 0
    property var loadFigures: []

    readonly property bool temperatureAvailable:
        root.temperaturePath !== ""

    readonly property string loadAverage:
        root.loadFigures.join("  ")

    property real lastCpuTotal: 0
    property real lastCpuBusy: 0
    property bool cpuSampled: false
    property real lastReceivedBytes: 0
    property real lastTransmittedBytes: 0
    property real lastTrafficAt: 0
    property bool trafficSampled: false

    onInterfaceNameChanged: root.forgetTraffic()

    function slurp(path: string): string {
        const view = reader.createObject(root, { path: path });
        const contents = view.text();
        view.destroy();
        return contents;
    }

    function wordsIn(line: string): var {
        return line.trim().split(/\s+/);
    }

    function absorbCpu(text: string): void {
        const fields = root.wordsIn(text.split("\n")[0])
            .slice(1).map(Number);
        if (fields.length <= root.cpuIowaitField) return;
        const total = fields.reduce(
            (sum, value) => sum + value, 0);
        const busy = total - fields[root.cpuIdleField]
            - fields[root.cpuIowaitField];
        const totalDelta = total - root.lastCpuTotal;
        const busyDelta = busy - root.lastCpuBusy;
        root.lastCpuTotal = total;
        root.lastCpuBusy = busy;
        if (!root.cpuSampled) {
            root.cpuSampled = true;
            return;
        }
        if (totalDelta <= 0) return;
        root.cpuPercent = Math.round(
            busyDelta / totalDelta * root.percentScale);
    }

    function bytesFrom(text: string, key: string): real {
        const line = text.split("\n").find(
            entry => entry.startsWith(`${key}:`));
        if (!line) return 0;
        return Number(root.wordsIn(line)[1])
            * root.bytesPerKibibyte;
    }

    function absorbMemory(text: string): void {
        const total = root.bytesFrom(text, root.memoryTotalKey);
        root.memoryTotalBytes = total;
        root.memoryUsedBytes = total
            - root.bytesFrom(text, root.memoryAvailableKey);
    }

    function absorbUptime(text: string): void {
        root.uptimeSeconds = Number(root.wordsIn(text)[0]) || 0;
    }

    function absorbLoad(text: string): void {
        root.loadFigures =
            root.wordsIn(text).slice(0, root.loadFigureCount);
    }

    function isDefaultRoute(line: string): bool {
        const fields = root.wordsIn(line);
        return fields[root.routeDestinationField]
                === root.defaultRouteHex
            && fields[root.routeMaskField] === root.defaultRouteHex;
    }

    function absorbRoute(text: string): void {
        const line = text.split("\n").slice(1)
            .find(entry => root.isDefaultRoute(entry));
        root.interfaceName = line
            ? root.wordsIn(line)[root.routeInterfaceField]
            : "";
    }

    function forgetTraffic(): void {
        root.trafficSampled = false;
        root.downloadBytesPerSecond = 0;
        root.uploadBytesPerSecond = 0;
    }

    function trafficLine(text: string): string {
        if (root.interfaceName === "") return "";
        return text.split("\n").find(entry =>
            entry.split(":")[0].trim() === root.interfaceName) ?? "";
    }

    function rateFrom(current: real, previous: real,
        span: real): real {
        return Math.max(0, (current - previous) / span);
    }

    function absorbTraffic(text: string): void {
        const line = root.trafficLine(text);
        if (line === "") {
            root.forgetTraffic();
            return;
        }
        const fields = root.wordsIn(line.split(":")[1]).map(Number);
        const received = fields[root.receivedBytesField];
        const sent = fields[root.transmittedBytesField];
        const now = Date.now();
        const span = (now - root.lastTrafficAt)
            / root.millisecondsPerSecond;
        if (root.trafficSampled && span > 0) {
            root.downloadBytesPerSecond = root.rateFrom(
                received, root.lastReceivedBytes, span);
            root.uploadBytesPerSecond = root.rateFrom(
                sent, root.lastTransmittedBytes, span);
        }
        root.lastReceivedBytes = received;
        root.lastTransmittedBytes = sent;
        root.lastTrafficAt = now;
        root.trafficSampled = true;
    }

    function absorbTemperature(text: string): void {
        root.temperatureCelsius =
            Number(text.trim()) / root.millidegreesPerDegree;
    }

    function absorbSensor(text: string): void {
        const line = text.trim().split("\n")[0] ?? "";
        if (line === "") return;
        const directory = line.slice(0, line.lastIndexOf("/"));
        root.temperaturePath =
            `${directory}/${root.temperatureSensor}`;
    }

    function absorbDisk(text: string): void {
        const fields =
            root.wordsIn(text.trim().split("\n")[1] ?? "")
                .map(Number);
        root.diskTotalBytes = fields[root.diskSizeField] || 0;
        root.diskFreeBytes = fields[root.diskAvailableField] || 0;
    }

    function absorbAddress(text: string): void {
        const line = text.split("\n").find(entry =>
            root.wordsIn(entry)[root.addressInterfaceField]
                === root.interfaceName) ?? "";
        const value =
            root.wordsIn(line)[root.addressValueField] ?? "";
        root.addressIpv4 = value.split("/")[0];
    }

    function sample(): void {
        root.absorbCpu(root.slurp(root.statPath));
        root.absorbMemory(root.slurp(root.memoryPath));
        root.absorbUptime(root.slurp(root.uptimePath));
        root.absorbLoad(root.slurp(root.loadPath));
        root.absorbRoute(root.slurp(root.routePath));
        root.absorbTraffic(root.slurp(root.trafficPath));
        if (!root.temperatureAvailable) return;
        root.absorbTemperature(root.slurp(root.temperaturePath));
    }

    function sampleSlowly(): void {
        if (!disk.running) disk.running = true;
        if (!address.running) address.running = true;
    }

    function padded(value: int): string {
        return `${value}`.padStart(root.minuteDigits, "0");
    }

    function formatBytes(bytes: real): string {
        let value = Math.max(0, bytes);
        let step = 0;
        while (value >= root.bytesPerKibibyte
            && step < root.byteUnits.length - 1) {
            value /= root.bytesPerKibibyte;
            step++;
        }
        const digits = step === 0 ? 0 : root.byteFractionDigits;
        return `${value.toFixed(digits)} ${root.byteUnits[step]}`;
    }

    function formatRate(bytesPerSecond: real): string {
        return `${root.formatBytes(bytesPerSecond)}/s`;
    }

    function formatDuration(seconds: real): string {
        const minutes = Math.floor(
            Math.max(0, seconds) / root.secondsPerMinute);
        const hours = Math.floor(minutes / root.minutesPerHour);
        const days = Math.floor(hours / root.hoursPerDay);
        if (days > 0)
            return `${days}d ${hours % root.hoursPerDay}h`;
        if (hours > 0)
            return `${hours}h `
                + `${root.padded(minutes % root.minutesPerHour)}m`;
        return `${minutes}m`;
    }

    Component.onCompleted: {
        sensor.running = true;
        root.sample();
        root.sampleSlowly();
    }

    Component {
        id: reader

        FileView {
            blockLoading: true
            printErrors: false
        }
    }

    Process {
        id: sensor

        command: ["sh", "-c", root.sensorProbe]

        stdout: StdioCollector {
            onStreamFinished: root.absorbSensor(this.text)
        }
    }

    Process {
        id: disk

        command: ["df", "-B1", "--output=size,avail",
            root.diskMount]

        stdout: StdioCollector {
            onStreamFinished: root.absorbDisk(this.text)
        }
    }

    Process {
        id: address

        command: ["ip", "-4", "-o", "addr", "show",
            "scope", "global"]

        stdout: StdioCollector {
            onStreamFinished: root.absorbAddress(this.text)
        }
    }

    Timer {
        running: true
        interval: root.pollIntervalMs
        repeat: true

        onTriggered: root.sample()
    }

    Timer {
        running: true
        interval: root.slowPollIntervalMs
        repeat: true

        onTriggered: root.sampleSlowly()
    }
}
