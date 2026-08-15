pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property int sampleMs: 1000
    readonly property int millisecondsPerSecond: 1000
    readonly property int countersPerSample: 2
    readonly property int bytesPerKilobyte: 1024
    readonly property int decimalsShown: 1

    readonly property int bytesPerMegabyte:
        root.bytesPerKilobyte * root.bytesPerKilobyte
    readonly property int bytesPerGigabyte:
        root.bytesPerMegabyte * root.bytesPerKilobyte

    readonly property var rateUnits: [
        { floor: root.bytesPerGigabyte, suffix: "GB/s" },
        { floor: root.bytesPerMegabyte, suffix: "MB/s" },
        { floor: root.bytesPerKilobyte, suffix: "kB/s" },
        { floor: 0, suffix: "B/s" }
    ]

    property bool watching: false
    property var previous: null

    property real downBytesPerSecond: 0
    property real upBytesPerSecond: 0

    readonly property bool sampled: root.previous !== null

    readonly property string statisticsDir:
        `/sys/class/net/${NetworkLink.interfaceName}/statistics`

    readonly property bool ready:
        root.watching && NetworkLink.interfaceName !== ""

    readonly property string downText:
        root.rateText(root.downBytesPerSecond)
    readonly property string upText:
        root.rateText(root.upBytesPerSecond)

    function rateText(perSecond: real): string {
        if (!root.sampled) return "Not sampled yet";
        const unit = root.rateUnits.find(
            candidate => perSecond >= candidate.floor);
        if (unit.floor === 0) {
            return `${Math.round(perSecond)} ${unit.suffix}`;
        }
        const scaled = perSecond / unit.floor;
        return `${scaled.toFixed(root.decimalsShown)} ${unit.suffix}`;
    }

    function forget(): void {
        root.previous = null;
        root.downBytesPerSecond = 0;
        root.upBytesPerSecond = 0;
    }

    function settle(sample: var): void {
        const before = root.previous;
        root.previous = sample;
        if (!before || sample.at <= before.at) return;
        const seconds =
            (sample.at - before.at) / root.millisecondsPerSecond;
        root.downBytesPerSecond =
            Math.max(0, (sample.received - before.received) / seconds);
        root.upBytesPerSecond =
            Math.max(0, (sample.sent - before.sent) / seconds);
    }

    function absorb(payload: string): void {
        const counters = payload.trim().split("\n");
        if (counters.length < root.countersPerSample) return;
        root.settle({
            received: Number(counters[0]),
            sent: Number(counters[1]),
            at: Date.now()
        });
    }

    function sample(): void {
        if (reader.running) return;
        reader.running = true;
    }

    onReadyChanged: {
        root.forget();
        if (root.ready) root.sample();
    }

    Timer {
        running: root.ready
        repeat: true
        interval: root.sampleMs

        onTriggered: root.sample()
    }

    Process {
        id: reader

        command: ["cat",
            `${root.statisticsDir}/rx_bytes`,
            `${root.statisticsDir}/tx_bytes`]

        stdout: StdioCollector {
            onStreamFinished: root.absorb(this.text)
        }
    }
}
