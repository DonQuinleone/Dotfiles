import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services

PanelWindow {
    id: root

    required property var modelData

    readonly property url source: Theme.wallpaper

    screen: root.modelData
    color: Theme.palette.bg ?? "black"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.namespace: "donbox-wallpaper"

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    onSourceChanged: root.crossfade()
    Component.onCompleted: root.crossfade()

    function crossfade(): void {
        if (incoming.source === root.source) return;
        outgoing.source = incoming.source;
        incoming.opacity = 0;
        incoming.source = root.source;
    }

    Image {
        id: outgoing

        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: false
    }

    Image {
        id: incoming

        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: false
        opacity: 0

        onStatusChanged: if (this.status === Image.Ready) fade.restart()
    }

    NumberAnimation {
        id: fade

        target: incoming
        property: "opacity"
        to: 1
        duration: Theme.duration("slow")
        easing.type: Theme.easing("standard")
    }
}
