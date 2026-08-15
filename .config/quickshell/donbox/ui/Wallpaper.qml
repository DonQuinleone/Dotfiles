import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services

PanelWindow {
    id: root

    required property var modelData

    readonly property url source: Theme.wallpaper

    readonly property bool plain: Theme.reduceMotion || Motion.reduced

    property bool flipped: false

    readonly property Image incoming: root.flipped ? second : first
    readonly property Image outgoing: root.flipped ? first : second

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

    onSourceChanged: root.load()
    Component.onCompleted: root.load()

    function load(): void {
        if (root.incoming.source === root.source) return;
        root.flipped = !root.flipped;
        blend.hold();
        root.incoming.source = root.source;
    }

    function reveal(): void {
        if (`${root.outgoing.source}` === "") {
            blend.settle();
            return;
        }
        blend.play(catalogue.next(root.plain));
    }

    WallpaperTransitions {
        id: catalogue
    }

    Image {
        id: first

        visible: false
        asynchronous: true
        cache: false

        onStatusChanged: if (this.status === Image.Ready
            && root.incoming === this) root.reveal()
    }

    Image {
        id: second

        visible: false
        asynchronous: true
        cache: false

        onStatusChanged: if (this.status === Image.Ready
            && root.incoming === this) root.reveal()
    }

    WallpaperBlend {
        id: blend

        anchors.fill: parent
        outgoing: root.outgoing
        incoming: root.incoming
    }
}
