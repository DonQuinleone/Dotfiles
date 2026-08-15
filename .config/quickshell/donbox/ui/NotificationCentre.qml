import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.services

PanelWindow {
    id: root

    required property var modelData

    readonly property real widthFactor: 1.5
    readonly property int panelWidth:
        (Theme.sizes.menuWidth ?? 0) * root.widthFactor
    readonly property int edge: Theme.spacing.section ?? 0
    readonly property int padding: Theme.sizes.popupPadding ?? 0

    readonly property bool focused:
        Hyprland.focusedMonitor?.name === root.modelData.name
    readonly property bool active:
        Notifications.centreOpen && root.focused

    readonly property var groups: root.group(NotificationStore.entries)

    screen: root.modelData
    visible: root.active || hold.running
    color: Qt.alpha(Theme.palette.bg ?? "black", 0)
    exclusionMode: ExclusionMode.Normal
    exclusiveZone: 0
    focusable: true
    implicitWidth: root.panelWidth
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "donbox-notifications"

    anchors {
        top: true
        right: true
        bottom: true
    }

    margins {
        top: root.edge
        right: root.edge
        bottom: root.edge
    }

    onActiveChanged: if (!root.active) hold.restart()

    function group(entries: var): var {
        const order = [];
        const byApp = ({});
        for (const item of entries) {
            if (!byApp[item.app]) {
                byApp[item.app] =
                    { app: item.app, icon: item.icon, items: [] };
                order.push(item.app);
            }
            byApp[item.app].items.push(item);
        }
        return order.map(app => byApp[app]);
    }

    Timer {
        id: hold

        interval: Theme.duration("normal")
    }

    PopoverGrab {
        surface: root
        shown: root.active

        onDismissed: Notifications.closeCentre()
    }

    Rectangle {
        id: frame

        anchors.fill: parent
        focus: true
        color: Theme.palette.bgAlt ?? "black"
        radius: Theme.radii.large ?? 0
        border.width: Theme.sizes.borderWidth ?? 0
        border.color: Theme.palette.border ?? "transparent"
        opacity: root.active ? (Theme.opacities.full ?? 1) : 0

        Keys.onEscapePressed: Notifications.closeCentre()

        transform: Translate {
            x: root.active ? 0 : root.panelWidth

            Behavior on x {
                NumberAnimation {
                    duration: Theme.duration("normal")
                    easing.type: Theme.easing("standard")
                }
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.duration("normal")
                easing.type: Theme.easing("standard")
            }
        }

        NotificationCentreHeader {
            id: header

            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: root.padding
        }

        Text {
            anchors.centerIn: parent
            visible: root.groups.length === 0
            text: "Nothing waiting"
            color: Theme.palette.fgDim ?? "white"
            font.family: Theme.fonts.ui ?? ""
            font.pixelSize: Theme.fontSizes.large ?? 0
        }

        ListView {
            anchors.top: header.bottom
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: root.padding
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            spacing: Theme.spacing.loose ?? 0
            model: root.groups

            delegate: NotificationGroup {
                width: ListView.view.width
            }
        }
    }
}
