import QtQuick
import qs.services

Row {
    id: root

    required property var reading

    readonly property string sunriseGlyph: "󰖛"
    readonly property string sunsetGlyph: "󰖚"

    readonly property int cells: 3
    readonly property int gap: Theme.spacing.tight ?? 0
    readonly property real faceScale: 1.6

    readonly property int cellWidth:
        (root.width - root.gap * (root.cells - 1)) / root.cells

    spacing: root.gap

    component Fact: Column {
        width: root.cellWidth
        spacing: Theme.spacing.hair ?? 0
    }

    component Face: Text {
        anchors.horizontalCenter: parent?.horizontalCenter
            ?? undefined
        color: Theme.palette.accentSoft ?? "white"
        font.family: Theme.fonts.mono ?? ""
        font.pixelSize:
            (Theme.sizes.iconNormal ?? 0) * root.faceScale
    }

    component Reading: Text {
        anchors.horizontalCenter: parent?.horizontalCenter
            ?? undefined
        color: Theme.palette.fg ?? "white"
        font.family: Theme.fonts.mono ?? ""
        font.pixelSize: Theme.fontSizes.normal ?? 0
        font.weight: Theme.fontWeights.bold ?? 0
        font.features: ({ "tnum": 1 })
    }

    component Caption: Text {
        anchors.horizontalCenter: parent?.horizontalCenter
            ?? undefined
        color: Theme.palette.fgDim ?? "white"
        font.family: Theme.fonts.ui ?? ""
        font.pixelSize: Theme.fontSizes.small ?? 0
    }

    Fact {
        Face {
            text: root.sunriseGlyph
        }

        Reading {
            text: root.reading.sunrise
        }

        Caption {
            text: "Sunrise"
        }
    }

    Fact {
        Face {
            text: root.sunsetGlyph
        }

        Reading {
            text: root.reading.sunset
        }

        Caption {
            text: "Sunset"
        }
    }

    Fact {
        MoonDial {
            anchors.horizontalCenter: parent.horizontalCenter
            implicitWidth:
                (Theme.sizes.iconNormal ?? 0) * root.faceScale
        }

        Reading {
            text: `${Math.round(Moon.illuminated * 100)}%`
        }

        Caption {
            text: Moon.label
        }
    }
}
