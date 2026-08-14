import QtQuick
import qs.services

SettingsSurface {
    id: root

    property alias text: input.text
    property string placeholder: ""

    signal accepted(string written)

    implicitWidth: Metrics.surfaceWidth
    activeFocusOnTab: true
    focused: input.activeFocus

    function focusText(): void {
        input.forceActiveFocus();
    }

    onActiveFocusChanged: if (root.activeFocus) input.forceActiveFocus()

    Text {
        anchors.fill: input
        anchors.verticalCenter: parent.verticalCenter
        verticalAlignment: Text.AlignVCenter
        visible: input.text === ""
        text: root.placeholder
        color: Theme.palette.fgDim ?? "white"
        font.family: Theme.fonts.ui ?? ""
        font.pixelSize: Theme.fontSizes.large ?? 0
    }

    TextInput {
        id: input

        anchors.fill: parent
        anchors.leftMargin: Theme.spacing.normal ?? 0
        anchors.rightMargin: Theme.spacing.normal ?? 0
        verticalAlignment: Text.AlignVCenter
        clip: true
        color: Theme.palette.fg ?? "white"
        selectionColor: Theme.palette.accent ?? "white"
        selectedTextColor: Theme.palette.bg ?? "black"
        font.family: Theme.fonts.ui ?? ""
        font.pixelSize: Theme.fontSizes.large ?? 0

        onEditingFinished: root.accepted(this.text)
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.IBeamCursor

        onClicked: input.forceActiveFocus()
    }
}
