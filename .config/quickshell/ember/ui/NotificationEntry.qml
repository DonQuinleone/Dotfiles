import QtQuick
import qs.services

Rectangle {
    id: root

    required property var modelData

    readonly property int padding: Theme.spacing.normal ?? 0
    readonly property color tint:
        Notifications.tint(root.modelData.urgency)
    readonly property bool actionable: root.modelData.live !== null
        && root.modelData.actions.length > 0

    implicitHeight: content.implicitHeight + root.padding * 2
    radius: Theme.radii.normal ?? 0
    color: Theme.palette.surface ?? "transparent"
    border.width: Theme.sizes.borderWidth ?? 0
    border.color: root.tint

    function stamp(millis: real): string {
        const when = new Date(millis);
        const today =
            when.toDateString() === new Date().toDateString();
        return Qt.formatDateTime(when,
            today ? "HH:mm" : "d MMM HH:mm");
    }

    Column {
        id: content

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: root.padding
        spacing: Theme.spacing.hair ?? 0

        Item {
            width: parent.width
            height: Theme.sizes.hitTarget ?? 0

            Text {
                anchors.left: parent.left
                anchors.right: time.left
                anchors.rightMargin: Theme.spacing.normal ?? 0
                anchors.verticalCenter: parent.verticalCenter
                visible: root.modelData.summary !== ""
                text: root.modelData.summary
                color: Theme.palette.fg ?? "white"
                font.family: Theme.fonts.ui ?? ""
                font.pixelSize: Theme.fontSizes.normal ?? 0
                font.weight: Theme.fontWeights.bold ?? 0
                elide: Text.ElideRight
            }

            Text {
                id: time

                anchors.right: close.left
                anchors.rightMargin: Theme.spacing.loose ?? 0
                anchors.verticalCenter: parent.verticalCenter
                text: root.stamp(root.modelData.time)
                color: Theme.palette.fgDim ?? "white"
                font.family: Theme.fonts.mono ?? ""
                font.pixelSize: Theme.fontSizes.small ?? 0
            }

            NotificationButton {
                id: close

                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: "✕"
                tint: Theme.palette.fgDim ?? "white"

                onActivated: NotificationStore.forget(root.modelData)
            }
        }

        Text {
            width: parent.width
            visible: root.modelData.body !== ""
            text: root.modelData.body
            textFormat: Text.StyledText
            color: Theme.palette.fg ?? "white"
            font.family: Theme.fonts.ui ?? ""
            font.pixelSize: Theme.fontSizes.normal ?? 0
            wrapMode: Text.WordWrap
            maximumLineCount: 3
            elide: Text.ElideRight
        }

        Flow {
            width: parent.width
            spacing: Theme.spacing.tight ?? 0
            visible: root.actionable

            Repeater {
                model: root.modelData.actions

                NotificationButton {
                    required property var modelData

                    text: this.modelData.text
                    tint: root.tint

                    onActivated: Notifications.trigger(
                        root.modelData, this.modelData.identifier)
                }
            }
        }
    }
}
