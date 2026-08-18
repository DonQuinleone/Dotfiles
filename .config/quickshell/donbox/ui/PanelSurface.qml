import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services

// A layer surface, not a popup: the compositor withholds
// pointer input from a popup held in a focus grab on a
// fractionally scaled output.
PanelWindow {
    id: root

    default property alias body: content.data

    // Every pane answers to the same name the pill toggles, so
    // this is the only place a pane decides it is on screen.
    required property string name

    property Item under: null

    // Every screen builds its own bar, so the caller says
    // which instance may map; two would cancel each other.
    property bool allowed: true

    property real widthFactor: 1.5
    property real screenShare: 0.7
    property int contentSpacing: Theme.spacing.loose ?? 0

    readonly property int panelWidth:
        (Theme.sizes.menuWidth ?? 0) * root.widthFactor
    readonly property int padding: Theme.sizes.popupPadding ?? 0
    readonly property int gap: Theme.spacing.tight ?? 0

    readonly property int tallest: root.screen
        ? root.screen.height * root.screenShare
        : content.implicitHeight

    readonly property real anchoredX: {
        if (!root.under || !root.visible) return root.gap;
        const centre = root.under.mapToItem(null,
            root.under.width / 2, 0).x;
        const rightmost = (root.screen?.width ?? root.panelWidth)
            - root.panelWidth - root.gap;
        return Math.max(root.gap,
            Math.min(centre - root.panelWidth / 2, rightmost));
    }

    screen: Panels.host?.screen ?? null
    visible: root.allowed && Panels.isOpen(root.name)
    color: Qt.alpha(Theme.palette.bg ?? "black", 0)
    exclusionMode: ExclusionMode.Normal
    exclusiveZone: 0
    focusable: true
    implicitWidth: root.panelWidth
    implicitHeight: frame.implicitHeight
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "donbox-pane"

    anchors {
        top: true
        left: true
    }

    margins {
        top: root.gap
        left: root.anchoredX
    }

    PopoverGrab {
        surface: root
        owner: Panels.host

        onDismissed: Panels.close()
    }

    Rectangle {
        id: frame

        anchors.fill: parent
        implicitHeight: scroller.height + root.padding * 2
        color: Theme.palette.bgAlt ?? "black"
        radius: Theme.radii.large ?? 0
        border.width: Theme.sizes.borderWidth ?? 0
        border.color: Theme.palette.border ?? "transparent"

        Flickable {
            id: scroller

            x: root.padding
            y: root.padding
            width: parent.width - root.padding * 2
                - Metrics.trackWidth
            height: Math.min(content.implicitHeight, root.tallest)
            contentWidth: this.width
            contentHeight: content.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            Column {
                id: content

                width: scroller.width
                spacing: root.contentSpacing
            }
        }

        ChooserScrollBar {
            anchors.top: scroller.top
            anchors.bottom: scroller.bottom
            anchors.right: parent.right
            anchors.rightMargin: root.padding
            view: scroller
        }
    }
}
