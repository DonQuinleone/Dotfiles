import QtQuick
import Quickshell.Io
import qs.services

Item {
    id: root

    required property string title
    required property string value

    readonly property int confirmMs: 1200
    readonly property string missingText: "Not available"

    readonly property bool present: root.value !== ""

    property bool copied: false

    implicitHeight: Math.max(
        Theme.sizes.hitTarget ?? 0, reading.implicitHeight)

    function copy(): void {
        if (!root.present || clipboard.running) return;
        clipboard.command = ["wl-copy", root.value];
        clipboard.running = true;
        root.copied = true;
        confirmation.restart();
    }

    // Qt hands the selection over only from a focused window, and
    // this popup never takes focus, so wl-copy owns it instead.
    Process {
        id: clipboard
    }

    Timer {
        id: confirmation

        interval: root.confirmMs

        onTriggered: root.copied = false
    }

    Column {
        id: reading

        anchors.left: parent.left
        anchors.right: action.left
        anchors.rightMargin: Theme.spacing.normal ?? 0
        anchors.verticalCenter: parent.verticalCenter

        Text {
            text: root.title
            color: Theme.palette.fgDim ?? "white"
            font.family: Theme.fonts.ui ?? ""
            font.pixelSize: Theme.fontSizes.small ?? 0
        }

        Text {
            width: parent.width
            elide: Text.ElideRight
            text: root.present ? root.value : root.missingText
            color: root.present
                ? (Theme.palette.fg ?? "white")
                : (Theme.palette.fgDim ?? "white")
            font.family: Theme.fonts.mono ?? ""
            font.pixelSize: Theme.fontSizes.normal ?? 0
            font.weight: Theme.fontWeights.medium ?? 0
        }
    }

    QuickChip {
        id: action

        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        visible: root.present
        glyph: root.copied ? "󰄬" : "󰆏"
        label: root.copied ? "Copied" : "Copy"
        selected: root.copied

        onActivated: root.copy()
    }
}
