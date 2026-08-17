import QtQuick
import qs.services

QuickSection {
    id: root

    required property var daemon

    // A delegate is built before its model row reaches it, so
    // every reading is asked for gently and the section simply
    // stays hidden until the daemon behind it exists.
    readonly property bool ready: root.daemon !== undefined

    readonly property bool linked: root.ready && root.daemon.up

    readonly property var facts: [
        { title: "Machine", value: root.daemon.machine },
        { title: "Address", value: root.daemon.address }
    ]

    title: root.ready ? root.daemon.label : ""
    visible: root.ready && root.daemon.present

    PanelEmpty {
        width: parent.width
        text: root.ready ? root.daemon.summary : ""
    }

    Repeater {
        model: root.linked ? root.facts : []

        NetworkFactRow {
            required property var modelData

            width: parent.width
            title: this.modelData.title
            value: this.modelData.value
        }
    }

    Repeater {
        model: root.ready ? root.daemon.warnings : []

        PanelEmpty {
            required property string modelData

            width: parent.width
            text: this.modelData
            color: Theme.palette.warn ?? "white"
        }
    }

    QuickChip {
        label: root.linked ? "Disconnect" : "Connect"
        selected: root.linked
        opacity: root.ready && root.daemon.busy
            ? (Theme.opacities.dim ?? 1)
            : (Theme.opacities.full ?? 1)

        onActivated: root.daemon.setUp(!root.daemon.up)
    }

    // Offered only while the link is up, since choosing a route
    // through a tunnel that is down does nothing worth showing.
    Repeater {
        model: root.linked ? root.daemon.exitNodes : []

        PanelRow {
            required property var modelData

            width: parent.width
            glyph: Vpn.idleGlyph
            title: this.modelData.name
            status: this.modelData.online
                ? "Exit node" : "Exit node, offline"
            actionLabel: this.modelData.active ? "Stop using" : "Use"
            actionOffered: !root.daemon.busy
            current: this.modelData.active === true

            onChosen: root.daemon.chooseExitNode(this.modelData.name)
        }
    }

    PanelEmpty {
        width: parent.width
        visible: root.ready && root.daemon.note !== ""
        text: root.ready ? root.daemon.note : ""
        color: Theme.palette.warn ?? "white"
    }
}
