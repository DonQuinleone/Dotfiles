import QtQuick
import qs.services

PanelSurface {
    id: root

    readonly property var facts: [
        { title: "IP address", value: NetworkLink.hostAddress },
        { title: "Gateway", value: NetworkLink.gateway },
        { title: "DNS servers", value: NetworkLink.resolverText },
        { title: "Public IPv4", value: NetworkPublic.ipv4 },
        { title: "Public IPv6", value: NetworkPublic.ipv6 }
    ]

    readonly property var speedStreams: [
        {
            glyph: "󰇚",
            caption: "Down",
            value: NetworkSpeed.downText
        },
        {
            glyph: "󰕒",
            caption: "Up",
            value: NetworkSpeed.upText
        }
    ]

    onVisibleChanged: root.watch(root.visible)

    function watch(active: bool): void {
        NetworkLink.watching = active;
        NetworkThroughput.watching = active;
        NetworkReachability.watching = active;
        NetworkResolvers.watching = active;
        NetworkPublic.watching = active;
    }

    PanelHeadline {
        width: parent.width
        text: Connectivity.summary
    }

    QuickSection {
        width: parent.width
        title: "Throughput"

        NetworkStreamRow {
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
        title: "Speed"

        NetworkStreamRow {
            width: parent.width
            streams: root.speedStreams
        }

        Row {
            width: parent.width
            spacing: Theme.spacing.normal ?? 0

            QuickChip {
                glyph: "󰓅"
                label: NetworkSpeed.running ? "Measuring" : "Measure"
                selected: NetworkSpeed.running

                onActivated: NetworkSpeed.measure()
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: NetworkSpeed.words
                color: Theme.palette.fgDim ?? "white"
                font.family: Theme.fonts.ui ?? ""
                font.pixelSize: Theme.fontSizes.small ?? 0
            }
        }
    }
}
