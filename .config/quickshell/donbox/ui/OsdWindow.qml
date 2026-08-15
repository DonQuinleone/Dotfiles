import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.services

PanelWindow {
    id: root

    required property var modelData

    readonly property bool onFocused:
        Hyprland.focusedMonitor?.name === root.modelData.name

    readonly property int trackWidth: 320
    readonly property int trackHeight: 10
    readonly property int bottomGap: 96
    readonly property real riseFrom: 0.9

    readonly property var glyphs: ({
        volume: ["󰝟", "󰕿", "󰖀", "󰕾"],
        brightness: ["󰃞", "󰃟", "󰃠"]
    })

    readonly property string glyph: {
        const set = root.glyphs[Osd.kind] ?? [];
        if (set.length === 0) return "";
        if (Osd.kind === "volume" && Osd.muted) return set[0];
        const scale = Osd.kind === "volume" ? set.slice(1) : set;
        const index = Math.min(scale.length - 1,
            Math.floor(Osd.level * scale.length));
        return scale[Math.max(0, index)];
    }

    visible: Osd.visible && root.onFocused
    screen: root.modelData
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    implicitWidth: card.implicitWidth
    implicitHeight: card.implicitHeight

    anchors.bottom: true
    margins.bottom: root.bottomGap

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "donbox-osd"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    Rectangle {
        id: card

        anchors.centerIn: parent
        implicitWidth: row.implicitWidth
            + (Theme.spacing.section ?? 0) * 2
        implicitHeight: row.implicitHeight
            + (Theme.spacing.loose ?? 0) * 2
        radius: Theme.radii.large ?? 0
        color: Theme.palette.bgAlt ?? "black"
        border.width: Theme.sizes.borderWidth ?? 0
        border.color: Theme.palette.border ?? "grey"
        opacity: Osd.visible ? (Theme.opacities.full ?? 1) : 0
        scale: Osd.visible ? 1 : root.riseFrom

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.duration("quick")
                easing.type: Theme.easing("standard")
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: Theme.duration("quick")
                easing.type: Theme.easing("standard")
            }
        }

        Row {
            id: row

            anchors.centerIn: parent
            spacing: Theme.spacing.loose ?? 0

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.glyph
                color: Osd.muted && Osd.kind === "volume"
                    ? (Theme.palette.fgDim ?? "white")
                    : (Theme.palette.accent ?? "white")
                font.family: Theme.fonts.mono ?? ""
                font.pixelSize: Theme.fontSizes.display ?? 0
            }

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: root.trackWidth
                height: root.trackHeight
                radius: height / 2
                color: Theme.palette.surface ?? "grey"

                Rectangle {
                    width: parent.width
                        * Math.max(0, Math.min(1, Osd.level))
                    height: parent.height
                    radius: parent.radius
                    color: Osd.muted && Osd.kind === "volume"
                        ? (Theme.palette.fgDim ?? "white")
                        : (Theme.palette.accent ?? "white")

                    Behavior on width {
                        NumberAnimation {
                            duration: Theme.duration("quick")
                            easing.type: Theme.easing("standard")
                        }
                    }
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: `${Math.round(Osd.level * 100)}%`
                color: Theme.palette.fg ?? "white"
                font.family: Theme.fonts.mono ?? ""
                font.pixelSize: Theme.fontSizes.large ?? 0
                font.features: ({ "tnum": 1 })
            }
        }
    }
}
