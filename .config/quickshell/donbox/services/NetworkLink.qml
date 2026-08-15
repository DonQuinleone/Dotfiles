pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property int refreshMs: 5000

    readonly property var shownFields: [
        "GENERAL.DEVICE",
        "GENERAL.TYPE",
        "GENERAL.CON-UUID",
        "GENERAL.CONNECTION",
        "IP4.ADDRESS",
        "IP4.GATEWAY",
        "IP4.DNS",
        "IP6.DNS"
    ]

    property bool watching: false
    property var link: null

    readonly property bool routed: root.link !== null

    readonly property string interfaceName:
        root.link?.interfaceName ?? ""
    readonly property string kind: root.link?.kind ?? ""
    readonly property string connectionName:
        root.link?.connectionName ?? ""
    readonly property string connectionUuid:
        root.link?.connectionUuid ?? ""
    readonly property string address: root.link?.address ?? ""
    readonly property string gateway: root.link?.gateway ?? ""
    readonly property var resolvers: root.link?.resolvers ?? []

    readonly property string hostAddress: root.address.split("/")[0]

    readonly property bool wireless: root.kind === "wifi"

    readonly property string resolverText:
        root.resolvers.join(", ")

    function routedIn(payload: string): var {
        for (const fields of NetworkCli.blocksIn(payload)) {
            const gateway = NetworkCli.valueOf(fields, "IP4.GATEWAY");
            if (gateway === "") continue;
            return {
                interfaceName:
                    NetworkCli.valueOf(fields, "GENERAL.DEVICE"),
                kind: NetworkCli.valueOf(fields, "GENERAL.TYPE"),
                connectionName:
                    NetworkCli.valueOf(fields, "GENERAL.CONNECTION"),
                connectionUuid:
                    NetworkCli.valueOf(fields, "GENERAL.CON-UUID"),
                address: NetworkCli.valuesUnder(
                    fields, "IP4.ADDRESS")[0] ?? "",
                gateway: gateway,
                resolvers: NetworkCli.valuesUnder(fields, "IP4.DNS")
                    .concat(NetworkCli.valuesUnder(fields, "IP6.DNS"))
            };
        }
        return null;
    }

    function absorb(payload: string): void {
        root.link = root.routedIn(payload);
    }

    function refresh(): void {
        if (probe.running) return;
        probe.running = true;
    }

    onWatchingChanged: if (root.watching) root.refresh()

    Timer {
        running: root.watching
        repeat: true
        interval: root.refreshMs

        onTriggered: root.refresh()
    }

    Process {
        id: probe

        command: ["nmcli", "-t", "-f",
            root.shownFields.join(","), "device", "show"]

        stdout: StdioCollector {
            onStreamFinished: root.absorb(this.text)
        }
    }
}
