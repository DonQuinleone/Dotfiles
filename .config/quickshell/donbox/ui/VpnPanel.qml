import QtQuick
import qs.services

PanelSurface {
    id: root

    PanelHeadline {
        width: parent.width
        text: Vpn.summary
        color: Vpn.connected
            ? (Theme.palette.good ?? "white")
            : (Theme.palette.fg ?? "white")
    }

    Repeater {
        model: Vpn.daemons

        VpnDaemonSection {
            required property var modelData

            width: parent.width
            daemon: this.modelData
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
