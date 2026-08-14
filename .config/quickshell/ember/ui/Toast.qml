import QtQuick
import Quickshell.Widgets
import qs.services

Item {
    id: root

    required property var modelData

    readonly property var entry: root.modelData
    readonly property var notification: root.entry.notification

    readonly property color tint:
        Notifications.tint(root.notification.urgency)
    readonly property string urgencyLabel:
        Notifications.label(root.notification.urgency)
    readonly property string iconSource:
        Notifications.iconFor(root.notification)

    readonly property int thumbnailFactor: 2
    readonly property int progressFactor: 3

    readonly property int padding: Theme.sizes.popupPadding ?? 0
    readonly property int gap: Theme.spacing.tight ?? 0
    readonly property int thumbnailSize:
        (Theme.sizes.hitTarget ?? 0) * root.thumbnailFactor
    readonly property int progressHeight:
        (Theme.sizes.borderWidth ?? 0) * root.progressFactor

    implicitHeight: card.implicitHeight
    clip: true
    opacity: 0

    transform: Translate {
        id: slide
    }

    HoverHandler {
        id: hover

        onHoveredChanged: root.entry.paused = hover.hovered
    }

    Rectangle {
        id: card

        anchors.fill: parent
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
                ? Notifications.dismiss(root.entry)
                : Notifications.activate(root.entry)
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
                entry: root.entry
                tint: root.tint
                label: root.urgencyLabel
                iconSource: root.iconSource
            }

            Row {
                width: parent.width
                spacing: Theme.spacing.normal ?? 0

                ClippingRectangle {
                    id: thumbnail

                    width: root.thumbnailSize
                    height: root.thumbnailSize
                    visible: root.notification.image !== ""
                    radius: Theme.radii.normal ?? 0
                    color: Theme.palette.bg ?? "transparent"

                    Image {
                        anchors.fill: parent
                        source: root.notification.image
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
                        text: root.notification.summary
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
                        visible: root.notification.body !== ""
                        text: root.notification.body
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
                        visible: root.notification.actions.length > 0

                        Repeater {
                            model: root.notification.actions

                            NotificationButton {
                                required property var modelData

                                text: this.modelData.text
                                tint: root.tint

                                onActivated: Notifications.invoke(
                                    root.entry, this.modelData)
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
                width: parent.width * root.entry.progress
                height: parent.height
                radius: parent.radius
                color: root.tint
            }
        }
    }

    ParallelAnimation {
        running: true

        NumberAnimation {
            target: root
            property: "opacity"
            from: 0
            to: Theme.opacities.full ?? 1
            duration: Theme.duration("slow")
            easing.type: Theme.easing("standard")
        }

        NumberAnimation {
            target: slide
            property: "x"
            from: root.width
            to: 0
            duration: Theme.duration("slow")
            easing.type: Theme.easing("emphasised")
        }
    }

    ParallelAnimation {
        running: root.entry.closing

        NumberAnimation {
            target: root
            property: "opacity"
            to: 0
            duration: Theme.duration("normal")
            easing.type: Theme.easing("standard")
        }

        NumberAnimation {
            target: slide
            property: "x"
            to: root.width
            duration: Theme.duration("normal")
            easing.type: Theme.easing("standard")
        }

        NumberAnimation {
            target: root
            property: "height"
            to: 0
            duration: Theme.duration("normal")
            easing.type: Theme.easing("standard")
        }
    }
}
