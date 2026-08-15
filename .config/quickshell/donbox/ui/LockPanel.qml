import QtQuick
import Quickshell
import qs.services

Item {
    id: root

    readonly property string timeFormat: "HH:mm"
    readonly property string dateFormat: "dddd d MMMM"
    readonly property string prompt: "donbox@lock"
    readonly property string headline: "!! ACCESS DENIED"

    readonly property int shakeThrow: Theme.spacing.section ?? 0
    readonly property int shakeCycles: 2

    property real nudge: 0

    implicitWidth: frame.implicitWidth
    implicitHeight: frame.implicitHeight

    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }

    Connections {
        target: Lock

        function onRejected(): void {
            shake.restart();
        }
    }

    SequentialAnimation {
        id: shake

        SequentialAnimation {
            loops: root.shakeCycles

            NumberAnimation {
                target: root
                property: "nudge"
                to: root.shakeThrow
                duration: Theme.duration("quick")
                easing.type: Theme.easing("standard")
            }

            NumberAnimation {
                target: root
                property: "nudge"
                to: -root.shakeThrow
                duration: Theme.duration("quick")
                easing.type: Theme.easing("standard")
            }
        }

        NumberAnimation {
            target: root
            property: "nudge"
            to: 0
            duration: Theme.duration("quick")
            easing.type: Theme.easing("standard")
        }
    }

    CrtFrame {
        id: frame

        anchors.centerIn: parent
        anchors.horizontalCenterOffset: root.nudge
        width: this.implicitWidth
        height: this.implicitHeight
        title: root.prompt
        status: Qt.formatDateTime(clock.date, root.dateFormat)
        alarmed: Lock.denied

        Text {
            text: Qt.formatDateTime(clock.date, root.timeFormat)
            color: Theme.palette.fg ?? "white"
            font.family: Theme.fonts.mono ?? ""
            font.pixelSize: LockMetrics.clockSize
            font.weight: Theme.fontWeights.bold ?? 0
            font.features: ({ "tnum": 1 })
        }

        Text {
            text: LockMetrics.rule
            color: Theme.palette.border ?? "grey"
            font.family: Theme.fonts.mono ?? ""
            font.pixelSize: LockMetrics.traceSize
        }

        LockTrace {}

        LockPrompt {}

        Row {
            width: parent.width
            spacing: Theme.spacing.tight ?? 0
            visible: Lock.fingerprintReady
                && Lock.fingerprintNote !== ""

            Text {
                text: LockMetrics.fingerprintGlyph
                color: Theme.palette.good ?? "white"
                font.family: Theme.fonts.mono ?? ""
                font.pixelSize: LockMetrics.traceSize
            }

            Text {
                width: parent.width - this.x
                text: Lock.fingerprintNote
                color: Theme.palette.fgDim ?? "white"
                wrapMode: Text.WordWrap
                font.family: Theme.fonts.mono ?? ""
                font.pixelSize: LockMetrics.traceSize
            }
        }

        CrtSweep {
            width: parent.width
            visible: Lock.verifying
        }

        Rectangle {
            width: parent.width
            height: alert.implicitHeight
                + (Theme.spacing.normal ?? 0) * 2
            radius: Theme.radii.small ?? 0
            color: Theme.palette.bad ?? "red"
            visible: Lock.denied

            Column {
                id: alert

                anchors.centerIn: parent
                width: parent.width - (Theme.spacing.normal ?? 0) * 2
                spacing: Theme.spacing.hair ?? 0

                Text {
                    text: root.headline
                    color: Theme.readableOn(
                        Theme.palette.bad ?? "red")
                    font.family: Theme.fonts.mono ?? ""
                    font.pixelSize: LockMetrics.headingSize
                    font.weight: Theme.fontWeights.bold ?? 0
                }

                Text {
                    width: parent.width
                    text: Lock.notice
                    color: Theme.readableOn(
                        Theme.palette.bad ?? "red")
                    wrapMode: Text.WordWrap
                    font.family: Theme.fonts.mono ?? ""
                    font.pixelSize: LockMetrics.traceSize
                }
            }
        }

        Text {
            text: LockMetrics.rule
            color: Theme.palette.border ?? "grey"
            font.family: Theme.fonts.mono ?? ""
            font.pixelSize: LockMetrics.traceSize
        }

        LockStatusLine {}
    }
}
