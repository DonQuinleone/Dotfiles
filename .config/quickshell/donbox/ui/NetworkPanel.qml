import QtQuick
import qs.services

PanelSurface {
    id: root

    readonly property var facts: [
        { title: "IP address", value: NetworkLink.hostAddress },
        { title: "Gateway", value: NetworkLink.gateway },
        { title: "DNS servers", value: NetworkLink.resolverText }
    ]

    onVisibleChanged: root.watch(root.visible)

    function watch(active: bool): void {
        NetworkLink.watching = active;
        NetworkThroughput.watching = active;
        NetworkReachability.watching = active;
        NetworkResolvers.watching = active;
        Connectivity.setScanning(active);
    }

    function statusOf(candidate: var): string {
        const percent =
            Connectivity.percentFor(candidate.signalStrength);
        return `${Connectivity.statusOf(candidate)} · ${percent}%`;
    }

    PanelHeadline {
        width: parent.width
        text: Connectivity.summary
    }

    QuickSection {
        width: parent.width
        title: "Throughput"

        NetworkThroughputRow {
            width: parent.width
        }
    }

    QuickSection {
        width: parent.width
        title: "Latency"

        Repeater {
            model: NetworkReachability.hops

            NetworkHopRow {
                required property var modelData

                width: parent.width
                probe: this.modelData
            }
        }
    }

    QuickSection {
        width: parent.width
        title: "Addresses"

        Repeater {
            model: root.facts

            NetworkFactRow {
                required property var modelData

                width: parent.width
                title: this.modelData.title
                value: this.modelData.value
            }
        }
    }

    QuickSection {
        width: parent.width
        title: "DNS provider"

        NetworkResolverPicker {
            width: parent.width
        }
    }

    QuickSection {
        width: parent.width
        visible: Connectivity.wifiPresent && Connectivity.wifiEnabled
        title: "Available networks"

        PanelEmpty {
            width: parent.width
            visible: Connectivity.inRange.length === 0
            text: "Looking for networks."
        }

        Repeater {
            model: Connectivity.inRange

            PanelRow {
                required property var modelData

                width: parent.width
                glyph: Connectivity.glyphFor(
                    this.modelData.signalStrength)
                title: this.modelData.name
                status: root.statusOf(this.modelData)
                actionLabel: "Connect"
                actionOffered: Connectivity.joinable(this.modelData)
                current: this.modelData.connected

                onChosen: Connectivity.join(this.modelData)
            }
        }
    }
}
