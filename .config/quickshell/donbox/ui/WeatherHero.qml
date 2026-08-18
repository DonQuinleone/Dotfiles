import QtQuick
import qs.services

Item {
    id: root

    required property var reading

    readonly property int gap: Theme.spacing.normal ?? 0
    readonly property real glyphScale: 1.8

    implicitHeight: Math.max(face.implicitHeight,
        naming.implicitHeight, detail.implicitHeight)

    Text {
        id: face

        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        text: Weather.condition.glyph
        color: Theme.palette.accent ?? "white"
        font.family: Theme.fonts.mono ?? ""
        font.pixelSize:
            (Theme.fontSizes.display ?? 0) * root.glyphScale
    }

    Column {
        id: naming

        anchors.left: face.right
        anchors.leftMargin: root.gap
        anchors.verticalCenter: parent.verticalCenter

        Text {
            text: Weather.rounded(root.reading.temperature)
            color: Theme.palette.fg ?? "white"
            font.family: Theme.fonts.ui ?? ""
            font.pixelSize: (Theme.fontSizes.display ?? 0) * 1.4
            font.weight: Theme.fontWeights.bold ?? 0
            font.features: ({ "tnum": 1 })
        }

        Text {
            text: Weather.condition.label
            color: Theme.palette.fgDim ?? "white"
            font.family: Theme.fonts.ui ?? ""
            font.pixelSize: Theme.fontSizes.normal ?? 0
        }
    }

    Column {
        id: detail

        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.spacing.hair ?? 0

        component Reading: Text {
            anchors.right: parent?.right ?? undefined
            color: Theme.palette.fgDim ?? "white"
            font.family: Theme.fonts.ui ?? ""
            font.pixelSize: Theme.fontSizes.small ?? 0
            font.features: ({ "tnum": 1 })
        }

        Reading {
            text: `High ${Weather.rounded(root.reading.high)}`
        }

        Reading {
            text: `Low ${Weather.rounded(root.reading.low)}`
        }

        Reading {
            text: `Feels ${Weather.rounded(root.reading.apparent)}`
        }

        Reading {
            text: `${Math.round(root.reading.wind)} mph`
        }
    }
}
