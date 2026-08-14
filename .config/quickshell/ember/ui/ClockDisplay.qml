import QtQuick
import Quickshell
import qs.services

Item {
    id: root

    readonly property string timeFormat: "HH:mm"
    readonly property string dateFormat: "ddd d MMM"

    implicitWidth: layout.implicitWidth
        + (Theme.sizes.barPadding ?? 0) * 2
    implicitHeight: Theme.sizes.hitTarget ?? 0

    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }

    Row {
        id: layout

        anchors.centerIn: parent
        height: root.height
        spacing: Theme.spacing.normal ?? 0

        PillText {
            text: Qt.formatDateTime(clock.date, root.timeFormat)
            font.family: Theme.fonts.ui ?? ""
            font.pixelSize: Theme.fontSizes.display ?? 0
            font.weight: Theme.fontWeights.bold ?? 0
        }

        PillText {
            text: Qt.formatDateTime(clock.date, root.dateFormat)
            color: Theme.palette.fgDim ?? "white"
            font.family: Theme.fonts.ui ?? ""
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onClicked: calendar.visible = !calendar.visible
    }

    CalendarPopup {
        id: calendar

        today: clock.date
        anchor.item: root
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom
    }
}
