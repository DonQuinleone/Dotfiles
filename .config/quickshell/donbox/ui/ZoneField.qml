import QtQuick
import qs.services

Column {
    id: root

    readonly property int mostShown: 6

    readonly property var matches:
        WorldClocks.matching(field.text, root.mostShown)

    spacing: Theme.spacing.tight ?? 0

    function reset(): void {
        field.clear();
    }

    function take(zone: string): void {
        WorldClocks.add(zone);
        root.reset();
    }

    TextField {
        id: field

        width: parent.width
        placeholder: "Search zones, e.g. America/New York"

        onAccepted: {
            if (root.matches.length === 0) return;
            root.take(root.matches[0]);
        }

        onCancelled: root.reset()
    }

    Repeater {
        model: root.matches

        Rectangle {
            id: hit

            required property string modelData

            width: parent.width
            implicitHeight: Theme.sizes.hitTarget ?? 0
            radius: Theme.radii.normal ?? 0
            color: area.containsMouse
                ? (Theme.palette.surface ?? "transparent")
                : Qt.alpha(Theme.palette.surface ?? "black", 0)

            Text {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Theme.sizes.popupPadding ?? 0
                anchors.rightMargin: Theme.sizes.popupPadding ?? 0
                anchors.verticalCenter: parent.verticalCenter
                elide: Text.ElideRight
                text: WorldClocks.pretty(hit.modelData)
                color: Theme.palette.fg ?? "white"
                font.family: Theme.fonts.ui ?? ""
                font.pixelSize: Theme.fontSizes.normal ?? 0
            }

            MouseArea {
                id: area

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: root.take(hit.modelData)
            }
        }
    }
}
