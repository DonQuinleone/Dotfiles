import QtQuick
import Quickshell
import qs.services

Item {
    id: root

    readonly property string timeFormat: "HH:mm"
    readonly property string dateFormat: "dddd d MMMM"

    readonly property int shakeThrow: Theme.spacing.section ?? 0
    readonly property int shakeCycles: 2
    readonly property real alarmWeight: 2

    readonly property bool alarmed: Lock.notice !== ""

    property real nudge: 0

    implicitWidth: card.implicitWidth
    implicitHeight: card.implicitHeight

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

    Rectangle {
        id: card

        anchors.centerIn: parent
        anchors.horizontalCenterOffset: root.nudge
        implicitWidth: column.implicitWidth
            + (Theme.spacing.section ?? 0) * 2
        implicitHeight: column.implicitHeight
            + (Theme.spacing.section ?? 0) * 2
        radius: Theme.radii.large ?? 0
        color: Theme.palette.bgAlt ?? "black"
        border.width: (Theme.sizes.borderWidth ?? 0)
            * (root.alarmed ? root.alarmWeight : 1)
        border.color: root.alarmed
            ? (Theme.palette.bad ?? "red")
            : (Theme.palette.border ?? "grey")

        Behavior on border.color {
            ColorAnimation {
                duration: Theme.duration("quick")
            }
        }

        Column {
            id: column

            anchors.centerIn: parent
            spacing: Theme.spacing.loose ?? 0

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Qt.formatDateTime(clock.date, root.timeFormat)
                color: Theme.palette.fg ?? "white"
                font.family: Theme.fonts.ui ?? ""
                font.pixelSize: Metrics.lockClockSize
                font.weight: Theme.fontWeights.bold ?? 0
                font.features: ({ "tnum": 1 })
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Qt.formatDateTime(clock.date, root.dateFormat)
                color: Theme.palette.fgDim ?? "white"
                font.family: Theme.fonts.ui ?? ""
                font.pixelSize: Metrics.lockPromptSize
            }

            Item {
                width: 1
                height: Theme.spacing.section ?? 0
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                width: Metrics.lockFieldWidth
                text: Lock.instruction
                color: Theme.palette.accent ?? "white"
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                font.family: Theme.fonts.ui ?? ""
                font.pixelSize: Metrics.lockPromptSize
                font.weight: Theme.fontWeights.bold ?? 0
            }

            LockField {
                anchors.horizontalCenter: parent.horizontalCenter
            }

            LockProgress {
                anchors.horizontalCenter: parent.horizontalCenter
                visible: Lock.working
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                width: Metrics.lockFieldWidth
                visible: root.alarmed
                text: Lock.notice
                color: Theme.palette.bad ?? "red"
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                font.family: Theme.fonts.ui ?? ""
                font.pixelSize: Metrics.lockPromptSize
                font.weight: Theme.fontWeights.bold ?? 0
            }

            LockStatus {
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
}
