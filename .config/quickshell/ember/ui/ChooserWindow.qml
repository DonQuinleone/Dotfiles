import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services

PanelWindow {
    id: root

    default property alias content: body.data

    required property var modelData
    required property bool active
    required property string monitor

    property string prompt: ""
    property int surfaceWidth: Metrics.surfaceWidth
    property int contentHeight: 0
    property int count: 0
    property string emptyText: qsTr("No matches")
    property alias query: field.text
    property alias planar: field.planar
    property alias verticalStep: field.verticalStep

    signal moved(int delta)
    signal accepted
    signal cancelled

    readonly property int padding: Theme.sizes.popupPadding ?? 0

    screen: root.modelData
    visible: root.active && root.modelData.name === root.monitor
    color: Qt.alpha(Theme.palette.bg ?? "black",
        Theme.opacities.dim ?? 0)
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "ember-chooser"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    onVisibleChanged: if (root.visible) field.begin()

    MouseArea {
        anchors.fill: parent

        onClicked: root.cancelled()
    }

    Rectangle {
        id: frame

        anchors.centerIn: parent
        implicitWidth: root.surfaceWidth + root.padding * 2
        implicitHeight: layout.implicitHeight + root.padding * 2
        color: Theme.palette.bgAlt ?? "black"
        radius: Theme.radii.large ?? 0
        border.width: Theme.sizes.borderWidth ?? 0
        border.color: Theme.palette.accent ?? "transparent"

        MouseArea {
            anchors.fill: parent
        }

        Column {
            id: layout

            anchors.fill: parent
            anchors.margins: root.padding
            spacing: Metrics.gutter

            ChooserField {
                id: field

                width: parent.width
                prompt: root.prompt

                onMoved: delta => root.moved(delta)
                onAccepted: root.accepted()
                onCancelled: root.cancelled()
            }

            Rectangle {
                width: parent.width
                height: Theme.sizes.borderWidth ?? 0
                color: Theme.palette.border ?? "transparent"
            }

            Item {
                id: body

                width: parent.width
                height: root.contentHeight
            }

            Text {
                width: parent.width
                visible: root.count === 0
                horizontalAlignment: Text.AlignHCenter
                text: root.emptyText
                color: Theme.palette.fgDim ?? "white"
                font.family: Theme.fonts.ui ?? ""
                font.pixelSize: Theme.fontSizes.large ?? 0
            }
        }
    }
}
