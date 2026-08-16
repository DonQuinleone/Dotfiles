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
}
