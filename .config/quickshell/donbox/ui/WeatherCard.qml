import QtQuick
import qs.services

Rectangle {
    id: root

    readonly property var reading: Weather.reading
    readonly property bool told: Location.known
    readonly property bool shown: root.told && root.reading !== null
    readonly property int pad: Theme.sizes.popupPadding ?? 0

    // Somewhere to be is the one thing nobody can guess, so the
    // field stands open until it has been answered.
    property bool changing: false

    readonly property bool asking: root.changing || !root.told

    implicitHeight: layout.implicitHeight + root.pad * 2
    radius: Theme.radii.large ?? 0
    color: Theme.palette.surface ?? "transparent"
    border.width: Theme.sizes.borderWidth ?? 0
    border.color: Theme.palette.border ?? "transparent"

    function settle(): void {
        root.changing = false;
        finder.reset();
    }

    Column {
        id: layout

        x: root.pad
        y: root.pad
        width: parent.width - root.pad * 2
        spacing: Theme.spacing.normal ?? 0

        WeatherHero {
            width: parent.width
            visible: root.shown
            reading: root.reading ?? ({})
        }

        Rectangle {
            width: parent.width
            height: Theme.sizes.focusEdge ?? 0
            visible: root.shown
            color: Theme.palette.border ?? "transparent"
            opacity: Theme.opacities.edge ?? 1
        }

        SkyFacts {
            width: parent.width
            visible: root.shown
            reading: root.reading ?? ({})
        }

        Text {
            width: parent.width
            visible: root.told && !root.shown
            text: Weather.failed
                ? "The forecast could not be fetched."
                : "Fetching the forecast…"
            color: Theme.palette.fgDim ?? "white"
            font.family: Theme.fonts.ui ?? ""
            font.pixelSize: Theme.fontSizes.normal ?? 0
        }

        Text {
            width: parent.width
            visible: !root.told
            wrapMode: Text.WordWrap
            text: "Where are you? The weather, the sunrise and "
                + "the sunset all wait on the answer."
            color: Theme.palette.fgDim ?? "white"
            font.family: Theme.fonts.ui ?? ""
            font.pixelSize: Theme.fontSizes.normal ?? 0
        }

        LocationField {
            id: finder

            width: parent.width
            visible: root.asking

            onSettled: root.changing = false
        }

        Item {
            width: parent.width
            visible: root.told
            implicitHeight: Math.max(place.implicitHeight,
                change.implicitHeight)

            Text {
                id: place

                anchors.left: parent.left
                anchors.right: change.left
                anchors.rightMargin: Theme.spacing.tight ?? 0
                anchors.verticalCenter: parent.verticalCenter
                elide: Text.ElideRight
                text: Location.place?.name ?? ""
                color: Theme.palette.fgDim ?? "white"
                font.family: Theme.fonts.ui ?? ""
                font.pixelSize: Theme.fontSizes.small ?? 0
            }

            QuickChip {
                id: change

                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                label: root.changing ? "Done" : "Change"
                selected: root.changing

                onActivated: {
                    root.changing = !root.changing;
                    finder.reset();
                }
            }
        }
    }
}
