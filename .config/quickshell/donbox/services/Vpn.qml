pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property int refreshMs: 15000
    readonly property int tunnelColumns: 5
    readonly property string daemonUpState: "Connected"
    readonly property string netbirdLabel: "NetBird"

    readonly property var tunnelKinds: ["vpn", "wireguard"]

    readonly property var shownFields:
        ["NAME", "UUID", "TYPE", "DEVICE", "ACTIVE"]

    readonly property var deviceFields:
        ["GENERAL.DEVICE", "IP4.ADDRESS"]

    readonly property string idleGlyph: "󰖂"
    readonly property string linkedGlyph: "󰦝"

    property var report: null
    property var discovered: []
    property string netbirdDevice: ""
    property string busyUuid: ""
    property bool netbirdBusy: false

    readonly property var tunnels:
        root.discovered.filter(entry => root.keeps(entry))

    readonly property bool netbirdPresent: root.report !== null

    readonly property bool netbirdUp:
        root.report?.daemonStatus === root.daemonUpState

    readonly property string netbirdState:
        root.report?.daemonStatus ?? "Unavailable"

    readonly property string netbirdName: root.report?.fqdn ?? ""

    readonly property string netbirdAddress:
        (root.report?.netbirdIp ?? "").split("/")[0]

    readonly property int peersLinked:
        root.report?.peers?.connected ?? 0
    readonly property int peersKnown:
        root.report?.peers?.total ?? 0

    readonly property var linked:
        root.tunnels.filter(entry => entry.active)

    readonly property int linkedCount:
        root.linked.length + (root.netbirdUp ? 1 : 0)

    readonly property bool connected: root.linkedCount > 0

    readonly property bool available:
        root.netbirdPresent || root.tunnels.length > 0

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
        if (root.netbirdUp) return root.netbirdLabel;
        return root.linked[0].name;
    }

    readonly property string peerWords:
        `${root.peersLinked} of ${root.peersKnown} peers reachable`

    function tunnelFrom(columns: var): var {
        return {
            name: columns[0],
            uuid: columns[1],
            kind: columns[2],
            device: columns[3],
            active: columns[4] === "yes"
        };
    }

    function keeps(entry: var): bool {
        if (!root.tunnelKinds.includes(entry.kind)) return false;
        if (entry.device === "") return true;
        return entry.device !== root.netbirdDevice;
    }

    function statusOf(entry: var): string {
        if (entry.uuid === root.busyUuid) return "Working";
        return entry.active ? "Connected" : "Disconnected";
    }

    function absorbReport(payload: string): void {
        try {
            root.report = JSON.parse(payload);
        } catch (error) {
            root.report = null;
        }
    }

    function absorbTunnels(payload: string): void {
        root.discovered = NetworkCli.rowsIn(payload)
            .filter(columns => columns.length >= root.tunnelColumns)
            .map(columns => root.tunnelFrom(columns));
    }

    // NetBird's own interface is a WireGuard link NetworkManager
    // also reports, so it is matched by the address NetBird
    // claims rather than by a guessed interface name.
    function absorbDevices(payload: string): void {
        const wanted = root.netbirdAddress;
        for (const fields of NetworkCli.blocksIn(payload)) {
            const hosts = NetworkCli
                .valuesUnder(fields, "IP4.ADDRESS")
                .map(entry => entry.split("/")[0]);
            if (!hosts.includes(wanted)) continue;
            root.netbirdDevice =
                NetworkCli.valueOf(fields, "GENERAL.DEVICE");
            return;
        }
        root.netbirdDevice = "";
    }

    function refresh(): void {
        if (!reporter.running) reporter.running = true;
        if (!lister.running) lister.running = true;
    }

    function resolveDevice(): void {
        if (root.netbirdAddress === "") {
            root.netbirdDevice = "";
            return;
        }
        if (deviceReader.running) return;
        deviceReader.running = true;
    }

    function setNetbird(wanted: bool): void {
        if (root.netbirdBusy) return;
        root.netbirdBusy = true;
        netbirdSwitch.command = ["netbird", wanted ? "up" : "down"];
        netbirdSwitch.running = true;
    }

    function setTunnel(entry: var, wanted: bool): void {
        if (root.busyUuid !== "") return;
        root.busyUuid = entry.uuid;
        tunnelSwitch.command = ["nmcli", "connection",
            wanted ? "up" : "down", "uuid", entry.uuid];
        tunnelSwitch.running = true;
    }

    onNetbirdAddressChanged: root.resolveDevice()

    Component.onCompleted: root.refresh()

    Timer {
        running: true
        repeat: true
        interval: root.refreshMs

        onTriggered: root.refresh()
    }

    Process {
        id: reporter

        command: ["netbird", "status", "--json"]

        stdout: StdioCollector {
            onStreamFinished: root.absorbReport(this.text)
        }
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
        id: netbirdSwitch

        onExited: code => {
            root.netbirdBusy = false;
            root.refresh();
            if (code !== 0) {
                console.error("donbox: netbird refused that change");
            }
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
