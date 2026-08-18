import QtQuick
import qs.services

Rectangle {
    id: root

    readonly property var reading: Weather.reading
    readonly property bool told: Location.known
    readonly property bool shown: root.told && root.reading !== null
    readonly property int pad: Theme.sizes.popupPadding ?? 0

    property bool asking: false

    implicitHeight: layout.implicitHeight + root.pad * 2
    radius: Theme.radii.large ?? 0
    color: Theme.palette.surface ?? "transparent"
    border.width: Theme.sizes.borderWidth ?? 0
    border.color: Theme.palette.border ?? "transparent"

    function settle(): void {
        root.asking = !root.told;
    }

    Column {
        id: layout

        x: root.pad
        y: root.pad
        width: parent.width - root.pad * 2
        spacing: Theme.spacing.normal ?? 0

        WeatherHero {
            width: parent.width
            visible: root.shown && !root.asking
            reading: root.reading ?? ({})
        }

        Rectangle {
            width: parent.width
            height: Theme.sizes.focusEdge ?? 0
            visible: root.shown && !root.asking
            color: Theme.palette.border ?? "transparent"
            opacity: Theme.opacities.edge ?? 1
        }

        SkyFacts {
            width: parent.width
            visible: root.shown && !root.asking
            reading: root.reading ?? ({})
        }

        Text {
            width: parent.width
            visible: root.told && !root.shown && !root.asking
            text: Weather.failed
                ? "The forecast could not be fetched."
                : "Fetching the forecast…"
            color: Theme.palette.fgDim ?? "white"
            font.family: Theme.fonts.ui ?? ""
            font.pixelSize: Theme.fontSizes.normal ?? 0
        }

        Text {
            width: parent.width
            visible: !root.told && !root.asking
            wrapMode: Text.WordWrap
            text: "Say where you are for weather and sun times."
            color: Theme.palette.fgDim ?? "white"
            font.family: Theme.fonts.ui ?? ""
            font.pixelSize: Theme.fontSizes.normal ?? 0
        }

        LocationField {
            id: finder

            width: parent.width
            visible: root.asking

            onSettled: root.asking = false
        }

        Item {
            width: parent.width
            implicitHeight: place.implicitHeight

            Text {
                id: place

                anchors.left: parent.left
                anchors.right: change.left
                anchors.rightMargin: Theme.spacing.tight ?? 0
                anchors.verticalCenter: parent.verticalCenter
                elide: Text.ElideRight
                visible: root.told
                text: Location.place?.name ?? ""
                color: Theme.palette.fgDim ?? "white"
                font.family: Theme.fonts.ui ?? ""
                font.pixelSize: Theme.fontSizes.small ?? 0
            }

            QuickChip {
                id: change

                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                label: root.asking
                    ? "Cancel"
                    : (root.told ? "Change" : "Set location")
                selected: root.asking

                onActivated: {
                    root.asking = !root.asking;
                    if (!root.asking) finder.reset();
                }
            }
        }
    }
}
