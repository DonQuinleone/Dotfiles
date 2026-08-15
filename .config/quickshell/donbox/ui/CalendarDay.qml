import QtQuick
import qs.services

Rectangle {
    id: root

    required property date day
    required property date today
    required property date month

    readonly property bool inMonth:
        root.day.getMonth() === root.month.getMonth()
    readonly property bool isToday: root.sameDay(root.day, root.today)

    function sameDay(left: date, right: date): bool {
        return left.getFullYear() === right.getFullYear()
            && left.getMonth() === right.getMonth()
            && left.getDate() === right.getDate();
    }

    width: Theme.sizes.calendarCell ?? 0
    height: Theme.sizes.calendarCell ?? 0
    radius: Theme.radii.normal ?? 0
    color: root.isToday
        ? (Theme.palette.accent ?? "transparent")
        : Qt.alpha(Theme.palette.accent ?? "black", 0)

    Text {
        anchors.centerIn: parent
        text: root.day.getDate()
        color: {
            if (root.isToday) return Theme.palette.bg;
            if (root.inMonth) return Theme.palette.fg;
            return Theme.palette.border;
        }
        font.family: Theme.fonts.mono ?? ""
        font.pixelSize: Theme.fontSizes.normal ?? 0
        font.weight: root.isToday
            ? (Theme.fontWeights.bold ?? 0)
            : (Theme.fontWeights.regular ?? 0)
        font.features: ({ "tnum": 1 })
    }
}
