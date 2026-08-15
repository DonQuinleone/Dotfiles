pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string automaticLabel: "Automatic"
    readonly property string customLabel: "Custom"
    readonly property string listSeparator: ","

    readonly property var providers: [
        {
            label: root.automaticLabel,
            ipv4: [],
            ipv6: []
        },
        {
            label: "Cloudflare",
            ipv4: ["1.1.1.1", "1.0.0.1"],
            ipv6: ["2606:4700:4700::1111", "2606:4700:4700::1001"]
        },
        {
            label: "Quad9",
            ipv4: ["9.9.9.9", "149.112.112.112"],
            ipv6: ["2620:fe::fe", "2620:fe::9"]
        },
        {
            label: "Google",
            ipv4: ["8.8.8.8", "8.8.4.4"],
            ipv6: ["2001:4860:4860::8888", "2001:4860:4860::8844"]
        },
        {
            label: "OpenDNS",
            ipv4: ["208.67.222.222", "208.67.220.220"],
            ipv6: ["2620:119:35::35", "2620:119:53::53"]
        }
    ]

    readonly property var settingKeys:
        ["ipv4.dns", "ipv4.ignore-auto-dns"]

    property bool watching: false
    property bool applying: false
    property bool overridden: false
    property var configured: []

    readonly property bool ready:
        root.watching && NetworkLink.connectionUuid !== ""

    readonly property var chosen: {
        if (!root.overridden) return root.providers[0];
        return root.providers
            .filter(candidate => candidate.ipv4.length > 0)
            .find(candidate => root.matches(candidate)) ?? null;
    }

    readonly property string chosenLabel:
        root.chosen?.label ?? root.customLabel

    function matches(provider: var): bool {
        if (provider.ipv4.length !== root.configured.length) {
            return false;
        }
        return provider.ipv4.every(
            (address, place) => address === root.configured[place]);
    }

    function listed(value: string): var {
        if (value === "") return [];
        return value.split(root.listSeparator)
            .map(entry => entry.trim())
            .filter(entry => entry !== "");
    }

    function absorb(payload: string): void {
        const fields = NetworkCli.pairsIn(payload);
        root.configured =
            root.listed(NetworkCli.valueOf(fields, "ipv4.dns"));
        const manual =
            NetworkCli.valueOf(fields, "ipv4.ignore-auto-dns");
        root.overridden = manual === "yes";
    }

    function refresh(): void {
        if (reader.running) return;
        reader.running = true;
    }

    function settingsFor(provider: var): var {
        const manual = provider.ipv4.length > 0 ? "yes" : "no";
        return [
            "ipv4.dns", provider.ipv4.join(root.listSeparator),
            "ipv4.ignore-auto-dns", manual,
            "ipv6.dns", provider.ipv6.join(root.listSeparator),
            "ipv6.ignore-auto-dns", manual
        ];
    }

    function choose(provider: var): void {
        if (!root.ready || root.applying) return;
        root.applying = true;
        writer.command = ["nmcli", "connection", "modify",
            NetworkLink.connectionUuid].concat(
                root.settingsFor(provider));
        writer.running = true;
    }

    function reapply(): void {
        reloader.command =
            ["nmcli", "device", "reapply", NetworkLink.interfaceName];
        reloader.running = true;
    }

    onReadyChanged: if (root.ready) root.refresh()

    Process {
        id: reader

        command: ["nmcli", "-t", "-f", root.settingKeys.join(","),
            "connection", "show", NetworkLink.connectionUuid]

        stdout: StdioCollector {
            onStreamFinished: root.absorb(this.text)
        }
    }

    Process {
        id: writer

        onExited: code => {
            if (code !== 0) {
                root.applying = false;
                console.error("donbox: nmcli refused the DNS change");
                return;
            }
            root.reapply();
        }
    }

    Process {
        id: reloader

        onExited: {
            root.applying = false;
            root.refresh();
            NetworkLink.refresh();
        }
    }
}
