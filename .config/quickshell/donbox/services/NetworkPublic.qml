pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // A resolver answers with the address it was asked from, so
    // the lookup costs one packet and tells no web server
    // anything it did not already need in order to reply.
    readonly property var script:
        [Preferences.donbox, "network", "public"]

    property bool watching: false
    property string ipv4: ""
    property string ipv6: ""

    readonly property bool known: root.ipv4 !== "" || root.ipv6 !== ""

    function absorb(payload: string): void {
        for (const line of payload.trim().split("\n")) {
            const [key, value] = line.split("=");
            if (value === undefined) continue;
            if (key.trim() === "ipv4") root.ipv4 = value.trim();
            if (key.trim() === "ipv6") root.ipv6 = value.trim();
        }
    }

    function refresh(): void {
        if (probe.running) return;
        probe.running = true;
    }

    // The address only changes when the route does, so this is
    // asked once a pane opens rather than polled.
    onWatchingChanged: if (root.watching && !root.known) root.refresh()

    Process {
        id: probe

        command: root.script

        stdout: StdioCollector {
            onStreamFinished: root.absorb(this.text)
        }
    }

    Connections {
        target: Connectivity

        function onConnectedChanged(): void {
            root.ipv4 = "";
            root.ipv6 = "";
            if (root.watching) root.refresh();
        }
    }
}
