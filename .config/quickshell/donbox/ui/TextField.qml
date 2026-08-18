import QtQuick
import qs.services

Rectangle {
    id: root

    property alias text: input.text
    property alias font: input.font
    property alias horizontalAlignment: input.horizontalAlignment

    property string sample: ""
    property string placeholder: ""
    property bool valid: true

    readonly property bool empty: input.text === ""
    readonly property int padding: Theme.sizes.popupPadding ?? 0

    signal accepted
    signal cancelled

    function clear(): void {
        input.text = "";
    }

    function take(): void {
        input.forceActiveFocus();
    }

    implicitWidth: root.sample === ""
        ? (Theme.sizes.menuWidth ?? 0)
        : metrics.advanceWidth + root.padding * 2
    implicitHeight: Theme.sizes.hitTarget ?? 0
    radius: Theme.radii.normal ?? 0
    color: Theme.palette.surface ?? "transparent"
    border.width: Theme.sizes.borderWidth ?? 0
    border.color: input.activeFocus
        ? (Theme.palette.accent ?? "transparent")
        : (Theme.palette.border ?? "transparent")

    Behavior on border.color {
        ColorAnimation {
            duration: Theme.duration("quick")
            easing.type: Theme.easing("standard")
        }
    }

    TextMetrics {
        id: metrics

        font: input.font
        text: root.sample
    }

    Text {
        anchors.fill: input
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: input.horizontalAlignment
        visible: root.empty && !input.activeFocus
        text: root.placeholder
        color: Theme.palette.fgDim ?? "white"
        font: input.font
        elide: Text.ElideRight
    }

    TextInput {
        id: input

        anchors.fill: parent
        anchors.leftMargin: root.padding
        anchors.rightMargin: root.padding
        verticalAlignment: TextInput.AlignVCenter
        color: root.valid
            ? (Theme.palette.fg ?? "white")
            : (Theme.palette.bad ?? "white")
        selectionColor: Theme.palette.accent ?? "white"
        selectedTextColor: Theme.onAccent
        selectByMouse: true
        clip: true
        font.family: Theme.fonts.ui ?? ""
        font.pixelSize: Theme.fontSizes.normal ?? 0

        Keys.onReturnPressed: root.accepted()
        Keys.onEnterPressed: root.accepted()
        Keys.onEscapePressed: root.cancelled()
    }
}
