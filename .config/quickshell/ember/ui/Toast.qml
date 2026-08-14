import QtQuick
import Quickshell.Widgets
import qs.services

Item {
    id: root

    required property var toast

    readonly property var entry: root.toast.entry

    readonly property color tint: Notifications.tint(root.entry.urgency)
    readonly property string urgencyLabel:
        Notifications.label(root.entry.urgency)

    readonly property int thumbnailFactor: 2
    readonly property int progressFactor: 3

    readonly property int padding: Theme.sizes.popupPadding ?? 0
    readonly property int gap: Theme.spacing.tight ?? 0
    readonly property int thumbnailSize:
        (Theme.sizes.hitTarget ?? 0) * root.thumbnailFactor
    readonly property int progressHeight:
        (Theme.sizes.borderWidth ?? 0) * root.progressFactor

    property bool settled: false

    readonly property bool open: root.settled && !root.toast.closing

    implicitHeight: root.open ? card.implicitHeight + root.gap : 0
    opacity: root.open ? (Theme.opacities.full ?? 1) : 0
    clip: true

    transform: Translate {
        x: root.open ? 0 : root.width

        Behavior on x {
            ToastMotion {}
        }
    }

    Behavior on implicitHeight {
        ToastMotion {}
    }

    Behavior on opacity {
        ToastMotion {}
    }

    Component.onCompleted: root.settled = true

    HoverHandler {
        id: hover

        onHoveredChanged: root.toast.paused = hover.hovered
    }

    Rectangle {
        id: card

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        implicitHeight: content.implicitHeight + root.padding * 2
            + root.progressHeight + root.gap
        radius: Theme.radii.large ?? 0
        border.width: Theme.sizes.borderWidth ?? 0
        border.color: root.tint

        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: Theme.palette.surface ?? "black"
            }
            GradientStop {
                position: 1.0
                color: Theme.palette.bgAlt ?? "black"
            }
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.MiddleButton
            cursorShape: Qt.PointingHandCursor

            onClicked: mouse => mouse.button === Qt.MiddleButton
                ? Notifications.dismiss(root.toast)
                : Notifications.activate(root.toast)
        }

        Column {
            id: content

            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: root.padding
            spacing: root.gap

            ToastHeader {
                width: parent.width
                toast: root.toast
                tint: root.tint
                label: root.urgencyLabel
            }

            Row {
                width: parent.width
                spacing: Theme.spacing.normal ?? 0

                ClippingRectangle {
                    id: thumbnail

                    width: root.thumbnailSize
                    height: root.thumbnailSize
                    visible: root.entry.image !== ""
                    radius: Theme.radii.normal ?? 0
                    color: Theme.palette.bg ?? "transparent"

                    Image {
                        anchors.fill: parent
                        source: root.entry.image
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                    }
                }

                Column {
                    width: parent.width - (thumbnail.visible
                        ? thumbnail.width + parent.spacing : 0)
                    spacing: root.gap

                    Text {
                        width: parent.width
                        visible: root.entry.summary !== ""
                        text: root.entry.summary
                        color: Theme.palette.fg ?? "white"
                        font.family: Theme.fonts.ui ?? ""
                        font.pixelSize: Theme.fontSizes.large ?? 0
                        font.weight: Theme.fontWeights.bold ?? 0
                        wrapMode: Text.WordWrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                    }

                    Text {
                        width: parent.width
                        visible: root.entry.body !== ""
                        text: root.entry.body
                        textFormat: Text.StyledText
                        color: Theme.palette.fg ?? "white"
                        font.family: Theme.fonts.ui ?? ""
                        font.pixelSize: Theme.fontSizes.normal ?? 0
                        wrapMode: Text.WordWrap
                        maximumLineCount: 5
                        elide: Text.ElideRight
                    }

                    Flow {
                        width: parent.width
                        spacing: root.gap
                        visible: root.entry.actions.length > 0

                        Repeater {
                            model: root.entry.actions

                            NotificationButton {
                                required property var modelData

                                text: this.modelData.text
                                tint: root.tint

                                onActivated: Notifications.invoke(
                                    root.toast,
                                    this.modelData.identifier)
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: root.gap
            anchors.leftMargin: Theme.radii.large ?? 0
            anchors.rightMargin: Theme.radii.large ?? 0
            height: root.progressHeight
            radius: Theme.radii.round ?? 0
            color: Qt.alpha(Theme.palette.fgDim ?? "black",
                Theme.opacities.edge ?? 0)

            Rectangle {
                width: parent.width * root.toast.progress
                height: parent.height
                radius: parent.radius
                color: root.tint
            }
        }
    }
}
