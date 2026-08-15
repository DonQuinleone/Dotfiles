import QtQuick
import Quickshell
import qs.services

PopupWindow {
    id: root

    readonly property real widthFactor: 1.5
    readonly property real heightFactor: 2.6
    readonly property int savedShown: 4
    readonly property int nearbyShown: 6

    readonly property int panelWidth:
        (Theme.sizes.menuWidth ?? 0) * root.widthFactor
    readonly property int heightCeiling:
        (Theme.sizes.menuWidth ?? 0) * root.heightFactor

    readonly property int gap: Theme.spacing.tight ?? 0
    readonly property int padding: Theme.sizes.popupPadding ?? 0

    readonly property var facts: [
        { title: "IP address", value: NetworkLink.hostAddress },
        { title: "Gateway", value: NetworkLink.gateway },
        { title: "DNS servers", value: NetworkLink.resolverText }
    ]

    color: Qt.alpha(Theme.palette.bg ?? "black", 0)
    implicitWidth: frame.implicitWidth
    implicitHeight: frame.implicitHeight + root.gap
    visible: false

    onVisibleChanged: root.watch(root.visible)

    function watch(active: bool): void {
        NetworkLink.watching = active;
        NetworkThroughput.watching = active;
        NetworkReachability.watching = active;
        NetworkResolvers.watching = active;
        NetworkCatalogue.watching = active;
        Connectivity.setScanning(active);
        if (!active) NetworkQr.shown = false;
    }

    function scanStatus(candidate: var): string {
        const percent =
            Connectivity.percentFor(candidate.signalStrength);
        return `${Connectivity.statusOf(candidate)} · ${percent}%`;
    }

    PopoverGrab {
        surface: root
        shown: root.visible

        onDismissed: root.visible = false
    }

    Rectangle {
        id: frame

        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        implicitWidth: root.panelWidth
        implicitHeight: Math.min(
            content.implicitHeight + root.padding * 2,
            root.heightCeiling)
        color: Theme.palette.bgAlt ?? "black"
        radius: Theme.radii.large ?? 0
        border.width: Theme.sizes.borderWidth ?? 0
        border.color: Theme.palette.border ?? "transparent"

        Flickable {
            id: scroller

            anchors.fill: parent
            anchors.margins: root.padding
            contentHeight: content.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            Column {
                id: content

                width: scroller.width
                spacing: Theme.spacing.loose ?? 0

                Text {
                    width: parent.width
                    elide: Text.ElideRight
                    text: Connectivity.summary
                    color: Theme.palette.fg ?? "white"
                    font.family: Theme.fonts.ui ?? ""
                    font.pixelSize: Theme.fontSizes.display ?? 0
                    font.weight: Theme.fontWeights.bold ?? 0
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
                    title: "Saved networks"

                    NetworkList {
                        width: parent.width
                        total: NetworkCatalogue.saved.length
                        model: NetworkCatalogue.saved.slice(
                            0, root.savedShown)

                        delegate: NetworkListRow {
                            required property var modelData

                            width: parent.width
                            glyph: NetworkCatalogue.glyphFor(
                                this.modelData.kind)
                            title: this.modelData.name
                            status: NetworkCatalogue.statusOf(
                                this.modelData)
                            actionLabel: "Connect"
                            actionOffered: !this.modelData.active
                                && !NetworkCatalogue.busy
                            current: this.modelData.active

                            onChosen: NetworkCatalogue.activate(
                                this.modelData)
                        }
                    }
                }

                QuickSection {
                    width: parent.width
                    visible: Connectivity.wifiPresent
                        && Connectivity.wifiEnabled
                    title: "Nearby networks"

                    NetworkList {
                        width: parent.width
                        total: Connectivity.inRange.length
                        model: Connectivity.inRange.slice(
                            0, root.nearbyShown)

                        delegate: NetworkListRow {
                            required property var modelData

                            width: parent.width
                            glyph: Connectivity.glyphFor(
                                this.modelData.signalStrength)
                            title: this.modelData.name
                            status: root.scanStatus(this.modelData)
                            actionLabel: "Connect"
                            actionOffered: Connectivity.joinable(
                                this.modelData)
                            current: this.modelData.connected

                            onChosen: Connectivity.join(
                                this.modelData)
                        }
                    }
                }

                QuickSection {
                    width: parent.width
                    visible: NetworkQr.offered
                    title: "Share this network"

                    NetworkQrPanel {
                        width: parent.width
                    }
                }
            }
        }
    }
}
