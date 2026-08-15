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
    readonly property int slideOffset: Theme.spacing.section ?? 0

    readonly property bool focused:
        Hyprland.focusedMonitor?.name === root.modelData.name
    readonly property bool active: QuickSettings.shown && root.focused

    screen: root.modelData
    visible: root.active || hold.running
    color: Qt.alpha(Theme.palette.bg ?? "black", 0)
    exclusionMode: ExclusionMode.Normal
    exclusiveZone: 0
    focusable: true
    implicitWidth: root.panelWidth + root.edge
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "donbox-quick-settings"

    anchors {
        top: true
        right: true
        bottom: true
    }

    margins {
        top: root.edge
        bottom: root.edge
    }

    onActiveChanged: {
        if (root.active) {
            volume.focusTrack();
            return;
        }
        hold.restart();
    }

    // The surface stays the full height of the screen so the
    // compositor never resizes it; only the mask follows the
    // card, which is what animates.
    mask: Region {
        item: card
    }

    Timer {
        id: hold

        interval: Theme.duration("normal")
    }

    PopoverGrab {
        surface: root
        shown: root.active

        onDismissed: QuickSettings.hide()
    }

    Rectangle {
        id: card

        anchors.top: parent.top
        anchors.right: parent.right
        anchors.rightMargin: root.edge
        anchors.topMargin: root.active ? 0 : root.slideOffset
        width: root.panelWidth
        height: content.implicitHeight + root.padding * 2
        focus: true
        color: Theme.palette.bgAlt ?? "black"
        radius: Theme.radii.large ?? 0
        border.width: Theme.sizes.borderWidth ?? 0
        border.color: Theme.palette.border ?? "transparent"
        opacity: root.active ? (Theme.opacities.full ?? 1) : 0

        Keys.onEscapePressed: QuickSettings.hide()

        Behavior on anchors.topMargin {
            NumberAnimation {
                duration: Theme.duration("normal")
                easing.type: Theme.easing("standard")
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.duration("normal")
                easing.type: Theme.easing("standard")
            }
        }

        Column {
            id: content

            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: root.padding
            spacing: Theme.spacing.loose ?? 0

            Text {
                text: "Quick settings"
                color: Theme.palette.fg ?? "white"
                font.family: Theme.fonts.ui ?? ""
                font.pixelSize: Theme.fontSizes.display ?? 0
                font.weight: Theme.fontWeights.bold ?? 0
            }

            QuickSlider {
                id: volume

                width: parent.width
                title: "Volume"
                glyph: Osd.sinkMuted ? "󰝟" : "󰕾"
                value: Osd.volume
                words: Levels.volumeWords
                tint: Osd.sinkMuted
                    ? (Theme.palette.fgDim ?? "white")
                    : (Theme.palette.accent ?? "white")

                onMoved: fraction => Osd.setVolume(fraction)
            }

            QuickSlider {
                width: parent.width
                title: "Brightness"
                glyph: "󰃠"
                value: Osd.brightness
                words: Levels.brightnessWords

                onMoved: fraction => Osd.setBrightness(fraction)
            }

            QuickToggles {
                width: parent.width
            }

            QuickSection {
                width: parent.width
                visible: PowerMode.available
                title: "Power profile"

                QuickProfiles {
                    width: parent.width
                }
            }

            QuickSection {
                width: parent.width
                title: "Accent"

                QuickAccents {
                    width: parent.width
                }
            }

            QuickSection {
                width: parent.width
                title: "Magnifier"

                QuickZoom {
                    width: parent.width
                }
            }

            QuickSection {
                width: parent.width
                visible: BluetoothRadio.available
                    && BluetoothRadio.powered
                title: "Bluetooth devices"

                QuickDevices {
                    width: parent.width
                }
            }
        }
    }
}
