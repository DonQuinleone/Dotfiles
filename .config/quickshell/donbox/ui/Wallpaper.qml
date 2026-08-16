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

    // The reveal rides on the incoming picture reaching Ready,
    // which never happens when the slot being flipped to is
    // already holding that very file: assigning the same source
    // changes nothing, so no status arrives, and the blend sits
    // at zero showing the picture on its way out. Going back to
    // a wallpaper still resident in the other slot is the whole
    // of the case, and cycling themes does it constantly.
    function load(): void {
        if (root.incoming.source === root.source) return;
        root.flipped = !root.flipped;
        blend.hold();
        if (root.incoming.source === root.source
            && root.incoming.status === Image.Ready) {
            root.reveal();
            return;
        }
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
