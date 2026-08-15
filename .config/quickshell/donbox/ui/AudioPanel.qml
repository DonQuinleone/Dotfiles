import QtQuick
import Quickshell
import qs.services

PopupWindow {
    id: root

    readonly property real widthFactor: 1.5
    readonly property real screenShare: 0.7

    readonly property int panelWidth:
        (Theme.sizes.menuWidth ?? 0) * root.widthFactor
    readonly property int padding: Theme.sizes.popupPadding ?? 0
    readonly property int gap: Theme.spacing.tight ?? 0

    readonly property string outputKind: AudioDevices.outputKind

    readonly property int tallest: root.screen
        ? root.screen.height * root.screenShare
        : content.implicitHeight

    color: Qt.alpha(Theme.palette.bg ?? "black", 0)
    implicitWidth: root.panelWidth
    implicitHeight: frame.implicitHeight + root.gap
    visible: false

    PopoverGrab {
        surface: root
        shown: root.visible

        onDismissed: root.visible = false
    }

    Rectangle {
        id: frame

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
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
                spacing: Theme.spacing.loose ?? 0

                AudioMixerRow {
                    width: parent.width
                    visible: AudioDevices.present(root.outputKind)
                    title: "Output"
                    detail: AudioDevices.currentLabel(root.outputKind)
                    level: AudioDevices.volume(root.outputKind)
                    muted: AudioDevices.muted(root.outputKind)
                    maximum: AudioDevices.loudest

                    onMoved: wanted => AudioDevices.setVolume(
                        root.outputKind, wanted)
                    onMuteToggled:
                        AudioDevices.toggleMute(root.outputKind)
                }

                QuickSection {
                    width: parent.width
                    title: "Applications"

                    AudioStreamList {
                        width: parent.width
                    }
                }

                QuickSection {
                    width: parent.width
                    title: "Play sound through"

                    AudioDeviceList {
                        width: parent.width
                        kind: AudioDevices.outputKind
                    }
                }

                QuickSection {
                    width: parent.width
                    title: "Record sound from"

                    AudioDeviceList {
                        width: parent.width
                        kind: AudioDevices.inputKind
                    }
                }
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
