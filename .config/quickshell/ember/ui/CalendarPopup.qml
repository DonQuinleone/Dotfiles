import QtQuick
import Quickshell
import qs.services

PopupWindow {
    id: root

    required property date today

    readonly property int daysPerWeek: 7
    readonly property int weeksShown: 6
    readonly property var weekdayNames:
        ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    readonly property int gap: Theme.spacing.tight ?? 0

    property date shownMonth: root.today

    color: Qt.alpha(Theme.palette.bg ?? "black", 0)
    implicitWidth: frame.implicitWidth
    implicitHeight: frame.implicitHeight + root.gap
    visible: false

    onVisibleChanged: if (root.visible) root.shownMonth = root.today

    function startOfGrid(month: date): date {
        const first =
            new Date(month.getFullYear(), month.getMonth(), 1);
        const mondayIndex = (first.getDay() + 6) % root.daysPerWeek;
        return new Date(first.getFullYear(), first.getMonth(),
            1 - mondayIndex);
    }

    function cellDate(offset: int): date {
        const start = root.startOfGrid(root.shownMonth);
        return new Date(start.getFullYear(), start.getMonth(),
            start.getDate() + offset);
    }

    function shiftMonth(delta: int): void {
        root.shownMonth = new Date(root.shownMonth.getFullYear(),
            root.shownMonth.getMonth() + delta, 1);
    }

    Rectangle {
        id: frame

        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        implicitWidth: content.implicitWidth
            + (Theme.sizes.popupPadding ?? 0) * 2
        implicitHeight: content.implicitHeight
            + (Theme.sizes.popupPadding ?? 0) * 2
        color: Theme.palette.bgAlt ?? "black"
        radius: Theme.radii.large ?? 0
        border.width: Theme.sizes.borderWidth ?? 0
        border.color: Theme.palette.border ?? "transparent"

        Column {
            id: content

            anchors.centerIn: parent
            spacing: Theme.spacing.normal ?? 0

            Item {
                width: grid.width
                height: Theme.sizes.hitTarget ?? 0

                CalendarStepper {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    glyph: "‹"

                    onStepped: root.shiftMonth(-1)
                }

                Text {
                    anchors.centerIn: parent
                    text: Qt.formatDateTime(root.shownMonth,
                        "MMMM yyyy")
                    color: Theme.palette.fg ?? "white"
                    font.family: Theme.fonts.ui ?? ""
                    font.pixelSize: Theme.fontSizes.large ?? 0
                    font.weight: Theme.fontWeights.bold ?? 0
                }

                CalendarStepper {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    glyph: "›"

                    onStepped: root.shiftMonth(1)
                }
            }

            Row {
                Repeater {
                    model: root.weekdayNames

                    Text {
                        required property string modelData

                        width: Theme.sizes.calendarCell ?? 0
                        horizontalAlignment: Text.AlignHCenter
                        text: this.modelData
                        color: Theme.palette.fgDim ?? "white"
                        font.family: Theme.fonts.ui ?? ""
                        font.pixelSize: Theme.fontSizes.small ?? 0
                        font.weight: Theme.fontWeights.medium ?? 0
                    }
                }
            }

            Grid {
                id: grid

                columns: root.daysPerWeek

                Repeater {
                    model: root.daysPerWeek * root.weeksShown

                    CalendarDay {
                        required property int index

                        day: root.cellDate(this.index)
                        today: root.today
                        month: root.shownMonth
                    }
                }
            }
        }
    }
}
