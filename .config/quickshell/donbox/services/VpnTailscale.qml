pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string label: "Tailscale"
    readonly property string runningState: "Running"
    readonly property string glyph: "󰖂"

    // tailscaled keeps the operator check to itself rather than
    // putting it on the socket, which is world-writable, so
    // there is nothing to read beforehand: the refusal is the
    // only way to learn that this user may not steer it.
    readonly property string deniedMarker: "denied"
    readonly property string operatorHint:
        "Not permitted. Run once:  sudo tailscale set --operator=$USER"

    property var report: null
    property bool busy: false
    property string note: ""

    readonly property bool present: root.report !== null

    readonly property bool up:
        root.report?.BackendState === root.runningState

    readonly property string state:
        root.report?.BackendState ?? "Unavailable"

    readonly property string machine:
        (root.report?.Self?.DNSName ?? "").replace(/\.$/, "")

    readonly property string address:
        (root.report?.Self?.TailscaleIPs ?? [])[0] ?? ""

    readonly property var warnings: root.report?.Health ?? []

    readonly property var peers:
        Object.values(root.report?.Peer ?? ({}))

    readonly property int peersLinked:
        root.peers.filter(peer => peer.Online === true).length

    readonly property int peersKnown: root.peers.length

    readonly property var exitNodes: root.peers
        .filter(peer => peer.ExitNodeOption === true)
        .map(peer => ({
            name: peer.HostName,
            online: peer.Online === true,
            active: peer.ExitNode === true
        }))
        .sort((first, second) => first.name.localeCompare(second.name))

    readonly property string exitNodeName:
        root.exitNodes.find(node => node.active)?.name ?? ""

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

    // A refusal is worth more on screen than in a log, since the
    // one thing that clears it is a command the user has to run.
    function absorbRefusal(text: string): void {
        if (text.toLowerCase().includes(root.deniedMarker)) {
            root.note = root.operatorHint;
            return;
        }
        root.note = text.trim().split("\n")[0] ?? "";
    }

    function refresh(): void {
        if (!reporter.running) reporter.running = true;
    }

    function run(argv: var): void {
        if (root.busy) return;
        root.busy = true;
        root.note = "";
        control.command = argv;
        control.running = true;
    }

    function setUp(wanted: bool): void {
        root.run(["tailscale", wanted ? "up" : "down"]);
    }

    // An empty value is how tailscale is told to stop using one,
    // so the active node doubles as the way back to a direct
    // connection.
    function chooseExitNode(name: string): void {
        const wanted = name === root.exitNodeName ? "" : name;
        root.run(["tailscale", "set", `--exit-node=${wanted}`]);
    }

    Component.onCompleted: root.refresh()

    Process {
        id: reporter

        command: ["tailscale", "status", "--json"]

        stdout: StdioCollector {
            onStreamFinished: root.absorb(this.text)
        }
    }

    Process {
        id: control

        stderr: StdioCollector {
            onStreamFinished: root.absorbRefusal(this.text)
        }

        onExited: {
            root.busy = false;
            root.refresh();
        }
    }
}
