import QtQuick
import qs.services

Row {
    id: root

    required property var reading

    readonly property string sunriseGlyph: "󰖛"
    readonly property string sunsetGlyph: "󰖚"

    readonly property int cells: 3
    readonly property int gap: Theme.spacing.tight ?? 0
    readonly property real faceScale: 1.8

    readonly property int cellWidth:
        (root.width - root.gap * (root.cells - 1)) / root.cells

    // One height for whatever each cell leads with, so the
    // three readings sit on a line whether a glyph or a drawn
    // moon stands above them.
    readonly property int artHeight:
        (Theme.sizes.iconNormal ?? 0) * root.faceScale

    spacing: root.gap

    component Fact: Column {
        width: root.cellWidth
        spacing: Theme.spacing.hair ?? 0
    }

    component Art: Item {
        default property alias body: holder.data

        width: root.cellWidth
        height: root.artHeight

        Item {
            id: holder

            anchors.fill: parent
        }
    }

    component Face: Text {
        anchors.centerIn: parent
        color: Theme.palette.accentSoft ?? "white"
        font.family: Theme.fonts.mono ?? ""
        font.pixelSize: root.artHeight
    }

    component Reading: Text {
        width: root.cellWidth
        horizontalAlignment: Text.AlignHCenter
        color: Theme.palette.fg ?? "white"
        font.family: Theme.fonts.mono ?? ""
        font.pixelSize: Theme.fontSizes.normal ?? 0
        font.weight: Theme.fontWeights.bold ?? 0
        font.features: ({ "tnum": 1 })
    }

    component Caption: Text {
        width: root.cellWidth
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        color: Theme.palette.fgDim ?? "white"
        font.family: Theme.fonts.ui ?? ""
        font.pixelSize: Theme.fontSizes.small ?? 0
    }

    Fact {
        Art {
            Face {
                text: root.sunriseGlyph
            }
        }

        Reading {
            text: root.reading.sunrise
        }

        Caption {
            text: "Sunrise"
        }
    }

    Fact {
        Art {
            Face {
                text: root.sunsetGlyph
            }
        }

        Reading {
            text: root.reading.sunset
        }

        Caption {
            text: "Sunset"
        }
    }

    Fact {
        Art {
            MoonDial {
                anchors.centerIn: parent
                implicitWidth: root.artHeight
            }
        }

        Reading {
            text: `${Math.round(Moon.illuminated * 100)}%`
        }

        Caption {
            text: Moon.label
        }
    }
}
