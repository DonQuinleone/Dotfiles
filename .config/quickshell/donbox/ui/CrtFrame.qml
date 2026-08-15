import QtQuick
import qs.services

Item {
    id: root

    default property alias content: body.data

    property string title: ""
    property string status: ""
    property bool alarmed: false
    property int columnWidth: LockMetrics.terminalWidth

    readonly property real alarmWeight: 2
    readonly property int glow: Theme.sizes.focusGlow ?? 0
    readonly property int inset: Theme.spacing.section ?? 0

    readonly property color edge: root.alarmed
        ? (Theme.palette.bad ?? "red")
        : (Theme.palette.accent ?? "white")

    implicitWidth: root.columnWidth + (root.inset + root.glow) * 2
    implicitHeight: shell.implicitHeight + root.glow * 2

    Rectangle {
        anchors.fill: parent
        radius: (Theme.radii.normal ?? 0) + root.glow
        color: root.edge
        opacity: Theme.opacities.edge ?? 0

        Behavior on color {
            ColorAnimation {
                duration: Theme.duration("quick")
            }
        }
    }

    Column {
        id: shell

        anchors.fill: parent
        anchors.margins: root.glow

        Rectangle {
            id: bar

            width: parent.width
            height: caption.implicitHeight
                + (Theme.spacing.normal ?? 0) * 2
            color: root.edge

            Behavior on color {
                ColorAnimation {
                    duration: Theme.duration("quick")
                }
            }

            Row {
                id: caption

                anchors.fill: parent
                anchors.leftMargin: Theme.spacing.loose ?? 0
                anchors.rightMargin: Theme.spacing.loose ?? 0

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.title
                    color: Theme.readableOn(root.edge)
                    font.family: Theme.fonts.mono ?? ""
                    font.pixelSize: LockMetrics.traceSize
                    font.weight: Theme.fontWeights.bold ?? 0
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - this.x
                    text: root.status
                    color: Theme.readableOn(root.edge)
                    horizontalAlignment: Text.AlignRight
                    elide: Text.ElideRight
                    font.family: Theme.fonts.mono ?? ""
                    font.pixelSize: LockMetrics.traceSize
                    font.weight: Theme.fontWeights.bold ?? 0
                }
            }
        }

        Rectangle {
            id: pane

            width: parent.width
            height: this.implicitHeight
            implicitHeight: body.implicitHeight + root.inset * 2
            color: Theme.palette.bg ?? "black"
            border.width: (Theme.sizes.borderWidth ?? 0)
                * (root.alarmed ? root.alarmWeight : 1)
            border.color: root.edge

            Behavior on border.color {
                ColorAnimation {
                    duration: Theme.duration("quick")
                }
            }

            Column {
                id: body

                x: root.inset
                y: root.inset
                width: root.columnWidth
                spacing: Theme.spacing.loose ?? 0
            }
        }
    }
}
