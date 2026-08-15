import QtQuick
import Quickshell.Io

QtObject {
    id: root

    readonly property int packetsPerProbe: 3
    readonly property real gapSeconds: 0.3
    readonly property int waitSeconds: 2
    readonly property int repeatMs: 6000
    readonly property real unknownLatencyMs: -1
    readonly property int fullLossPercent: 100
    readonly property int latencyDecimals: 1

    readonly property var lossPattern:
        new RegExp("([\\d.]+)% packet loss")
    readonly property var latencyPattern:
        new RegExp("= [\\d.]+/([\\d.]+)/")

    required property string label

    property string host: ""
    property bool running: false
    property bool sampled: false
    property real lossPercent: 0
    property real averageMs: root.unknownLatencyMs

    readonly property bool ready: root.running && root.host !== ""

    readonly property bool reachable:
        root.sampled && root.lossPercent < root.fullLossPercent

    readonly property string latencyText: {
        if (!root.ready) return "Not measured";
        if (!root.sampled) return "Measuring";
        if (!root.reachable) return "No reply";
        return `${root.averageMs.toFixed(root.latencyDecimals)} ms`;
    }

    readonly property string lossText: {
        if (!root.ready || !root.sampled) return "";
        return `${Math.round(root.lossPercent)}% loss`;
    }

    function forget(): void {
        root.sampled = false;
        root.lossPercent = 0;
        root.averageMs = root.unknownLatencyMs;
    }

    function absorb(payload: string): void {
        const loss = payload.match(root.lossPattern);
        if (!loss) {
            root.forget();
            return;
        }
        const latency = payload.match(root.latencyPattern);
        root.lossPercent = Number(loss[1]);
        root.averageMs = latency
            ? Number(latency[1])
            : root.unknownLatencyMs;
        root.sampled = true;
    }

    function measure(): void {
        if (root.pinger.running) return;
        root.pinger.running = true;
    }

    onReadyChanged: {
        root.forget();
        if (root.ready) {
            root.measure();
            return;
        }
        root.pinger.running = false;
    }

    readonly property Timer schedule: Timer {
        running: root.ready
        repeat: true
        interval: root.repeatMs

        onTriggered: root.measure()
    }

    readonly property Process pinger: Process {
        command: ["ping", "-n", "-q",
            "-c", `${root.packetsPerProbe}`,
            "-i", `${root.gapSeconds}`,
            "-W", `${root.waitSeconds}`,
            root.host]

        stdout: StdioCollector {
            onStreamFinished: root.absorb(this.text)
        }
    }
}
