pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property int refreshMs: 15000
    readonly property int tunnelColumns: 5

    // NetworkManager carries the tunnels it dials itself. A
    // daemon that brings up its own interface is asked directly,
    // and each answers the same questions so the pane can draw
    // them from one description.
    readonly property var daemons: [VpnTailscale, VpnNetbird]

    readonly property var tunnelKinds: ["vpn", "wireguard"]

    readonly property var shownFields:
        ["NAME", "UUID", "TYPE", "DEVICE", "ACTIVE"]

    readonly property var deviceFields:
        ["GENERAL.DEVICE", "IP4.ADDRESS"]

    readonly property string idleGlyph: "󰖂"
    readonly property string linkedGlyph: "󰦝"

    property var discovered: []
    property var daemonDevices: []
    property string busyUuid: ""

    readonly property var tunnels:
        root.discovered.filter(entry => root.keeps(entry))

    readonly property var present:
        root.daemons.filter(daemon => daemon.present)

    readonly property var linkedDaemons:
        root.daemons.filter(daemon => daemon.up)

    readonly property var linked:
        root.tunnels.filter(entry => entry.active)

    readonly property int linkedCount:
        root.linked.length + root.linkedDaemons.length

    readonly property bool connected: root.linkedCount > 0

    readonly property bool available:
        root.present.length > 0 || root.tunnels.length > 0

    readonly property string glyph:
        root.connected ? root.linkedGlyph : root.idleGlyph

    readonly property color tint: root.connected
        ? (Theme.palette.good ?? "white")
        : (Theme.palette.fgDim ?? "white")

    readonly property string summary: {
        if (root.linkedCount === 0) return "Nothing connected";
        if (root.linkedCount > 1) {
            return `${root.linkedCount} connections`;
        }
        if (root.linkedDaemons.length === 1) {
            return root.linkedDaemons[0].label;
        }
        return root.linked[0].name;
    }

    readonly property var daemonAddresses: root.daemons
        .map(daemon => daemon.address)
        .filter(address => address !== "")

    function tunnelFrom(columns: var): var {
        return {
            name: columns[0],
            uuid: columns[1],
            kind: columns[2],
            device: columns[3],
            active: columns[4] === "yes"
        };
    }

    // A daemon's own interface is a link NetworkManager also
    // reports, so it is matched by the address the daemon claims
    // rather than by a guessed interface name, and dropped from
    // the tunnels it would otherwise duplicate.
    function keeps(entry: var): bool {
        if (!root.tunnelKinds.includes(entry.kind)) return false;
        if (entry.device === "") return true;
        return !root.daemonDevices.includes(entry.device);
    }

    function statusOf(entry: var): string {
        if (entry.uuid === root.busyUuid) return "Working";
        return entry.active ? "Connected" : "Disconnected";
    }

    function absorbTunnels(payload: string): void {
        root.discovered = NetworkCli.rowsIn(payload)
            .filter(columns => columns.length >= root.tunnelColumns)
            .map(columns => root.tunnelFrom(columns));
    }

    function absorbDevices(payload: string): void {
        const wanted = root.daemonAddresses;
        const found = [];
        for (const fields of NetworkCli.blocksIn(payload)) {
            const hosts = NetworkCli
                .valuesUnder(fields, "IP4.ADDRESS")
                .map(entry => entry.split("/")[0]);
            if (!hosts.some(host => wanted.includes(host))) continue;
            found.push(NetworkCli.valueOf(fields, "GENERAL.DEVICE"));
        }
        root.daemonDevices = found;
    }

    function refresh(): void {
        for (const daemon of root.daemons) daemon.refresh();
        if (!lister.running) lister.running = true;
    }

    function resolveDevices(): void {
        if (root.daemonAddresses.length === 0) {
            root.daemonDevices = [];
            return;
        }
        if (deviceReader.running) return;
        deviceReader.running = true;
    }

    function setTunnel(entry: var, wanted: bool): void {
        if (root.busyUuid !== "") return;
        root.busyUuid = entry.uuid;
        tunnelSwitch.command = ["nmcli", "connection",
            wanted ? "up" : "down", "uuid", entry.uuid];
        tunnelSwitch.running = true;
    }

    onDaemonAddressesChanged: root.resolveDevices()

    Component.onCompleted: root.refresh()

    Timer {
        running: true
        repeat: true
        interval: root.refreshMs

        onTriggered: root.refresh()
    }

    Process {
        id: lister

        command: ["nmcli", "-t", "-f",
            root.shownFields.join(","), "connection", "show"]

        stdout: StdioCollector {
            onStreamFinished: root.absorbTunnels(this.text)
        }
    }

    Process {
        id: deviceReader

        command: ["nmcli", "-t", "-f",
            root.deviceFields.join(","), "device", "show"]

        stdout: StdioCollector {
            onStreamFinished: root.absorbDevices(this.text)
        }
    }

    Process {
        id: tunnelSwitch

        onExited: code => {
            root.busyUuid = "";
            root.refresh();
            if (code !== 0) {
                console.error("donbox: nmcli refused that tunnel");
            }
        }
    }
}
