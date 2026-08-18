import QtQuick
import qs.services

Column {
    id: root

    signal settled

    spacing: Theme.spacing.tight ?? 0

    function reset(): void {
        field.clear();
        Location.settle("");
    }

    function take(found: var): void {
        Location.choose(found);
        root.reset();
        root.settled();
    }

    function submit(): void {
        const given = Location.coordinates(field.text);
        if (given) {
            root.take(given);
            return;
        }
        if (Location.results.length === 0) return;
        root.take(Location.results[0]);
    }

    TextField {
        id: field

        width: parent.width
        placeholder: "Search a place, or type 51.45, -2.58"

        onTextChanged: Location.settle(this.text)
        onAccepted: root.submit()
        onCancelled: root.reset()
    }

    Text {
        visible: Location.searching
        text: "Searching…"
        color: Theme.palette.fgDim ?? "white"
        font.family: Theme.fonts.ui ?? ""
        font.pixelSize: Theme.fontSizes.small ?? 0
    }

    Repeater {
        model: Location.results

        Rectangle {
            id: hit

            required property var modelData

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
                text: hit.modelData.name
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
