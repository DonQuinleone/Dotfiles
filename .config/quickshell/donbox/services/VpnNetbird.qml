pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string label: "NetBird"
    readonly property string connectedState: "Connected"
    readonly property string glyph: "󰖂"

    property var report: null
    property bool busy: false
    property string note: ""

    readonly property bool present: root.report !== null

    readonly property bool up:
        root.report?.daemonStatus === root.connectedState

    readonly property string state:
        root.report?.daemonStatus ?? "Unavailable"

    readonly property string machine: root.report?.fqdn ?? ""

    readonly property string address:
        (root.report?.netbirdIp ?? "").split("/")[0]

    readonly property var warnings: []

    readonly property int peersLinked:
        root.report?.peers?.connected ?? 0

    readonly property int peersKnown: root.report?.peers?.total ?? 0

    // NetBird routes through whichever peer advertises it rather
    // than letting one be picked here, so it offers none.
    readonly property var exitNodes: []
    readonly property string exitNodeName: ""

    readonly property string summary: root.up
        ? `${root.peersLinked} of ${root.peersKnown} peers reachable`
        : `Daemon ${root.state}`

    function absorb(payload: string): void {
        try {
            root.report = JSON.parse(payload);
        } catch (error) {
            root.report = null;
        }
    }

    function refresh(): void {
        if (!reporter.running) reporter.running = true;
    }

    function setUp(wanted: bool): void {
        if (root.busy) return;
        root.busy = true;
        root.note = "";
        control.command = ["netbird", wanted ? "up" : "down"];
        control.running = true;
    }

    function chooseExitNode(name: string): void {
    }

    Component.onCompleted: root.refresh()

    Process {
        id: reporter

        command: ["netbird", "status", "--json"]

        stdout: StdioCollector {
            onStreamFinished: root.absorb(this.text)
        }
    }

    Process {
        id: control

        stderr: StdioCollector {
            onStreamFinished: root.note =
                this.text.trim().split("\n")[0] ?? ""
        }

        onExited: {
            root.busy = false;
            root.refresh();
        }
    }
}
