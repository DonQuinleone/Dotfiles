import QtQuick
import qs.services

PanelSurface {
    id: root

    readonly property var facts: [
        { title: "Machine", value: Vpn.netbirdName },
        { title: "Address", value: Vpn.netbirdAddress }
    ]

    PanelHeadline {
        width: parent.width
        text: Vpn.summary
        color: Vpn.connected
            ? (Theme.palette.good ?? "white")
            : (Theme.palette.fg ?? "white")
    }

    QuickSection {
        width: parent.width
        visible: Vpn.netbirdPresent
        title: "NetBird"

        PanelEmpty {
            width: parent.width
            text: Vpn.netbirdUp
                ? Vpn.peerWords
                : `Daemon ${Vpn.netbirdState}`
        }

        Repeater {
            model: Vpn.netbirdUp ? root.facts : []

            NetworkFactRow {
                required property var modelData

                width: parent.width
                title: this.modelData.title
                value: this.modelData.value
            }
        }

        QuickChip {
            label: Vpn.netbirdUp ? "Disconnect" : "Connect"
            selected: Vpn.netbirdUp
            opacity: Vpn.netbirdBusy
                ? (Theme.opacities.dim ?? 1)
                : (Theme.opacities.full ?? 1)

            onActivated: Vpn.setNetbird(!Vpn.netbirdUp)
        }
    }

    QuickSection {
        width: parent.width
        title: "Tunnels"

        PanelEmpty {
            width: parent.width
            visible: Vpn.tunnels.length === 0
            text: "NetworkManager knows of no VPN connections."
        }

        Repeater {
            model: Vpn.tunnels

            PanelRow {
                required property var modelData

                width: parent.width
                glyph: Vpn.idleGlyph
                title: this.modelData.name
                status: Vpn.statusOf(this.modelData)
                actionLabel: this.modelData.active
                    ? "Disconnect"
                    : "Connect"
                actionOffered: Vpn.busyUuid === ""
                current: this.modelData.active

                onChosen: Vpn.setTunnel(this.modelData,
                    !this.modelData.active)
            }
        }
    }
}
