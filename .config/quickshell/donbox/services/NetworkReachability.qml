pragma Singleton

import Quickshell

Singleton {
    id: root

    readonly property string internetHost: "1.1.1.1"

    property bool watching: false

    readonly property NetworkProbe router: NetworkProbe {
        label: "Router"
        host: NetworkLink.gateway
        running: root.watching
    }

    readonly property NetworkProbe internet: NetworkProbe {
        label: "Internet"
        host: root.internetHost
        running: root.watching
    }

    readonly property var hops: [root.router, root.internet]
}
