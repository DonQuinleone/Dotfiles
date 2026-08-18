import QtQuick
import qs.services

PanelSurface {
    id: root

    required property date today

    readonly property int daysPerWeek: 7
    readonly property int weeksShown: 6

    readonly property var weekdayNames:
        ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    readonly property string backGlyph: "‹"
    readonly property string onGlyph: "›"

    property date shownMonth: root.today

    onVisibleChanged: root.settle(root.visible)

    function settle(shown: bool): void {
        WorldClocks.watching = shown;
        if (!shown) return;
        root.shownMonth = root.today;
        alarmEditor.reset();
        zoneField.reset();
        WorldClocks.listZones();
    }

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

    Item {
        width: parent.width
        height: Theme.sizes.hitTarget ?? 0

        Stepper {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            glyph: root.backGlyph

            onStepped: root.shiftMonth(-1)
        }

        Text {
            anchors.centerIn: parent
            text: Qt.formatDateTime(root.shownMonth, "MMMM yyyy")
            color: Theme.palette.fg ?? "white"
            font.family: Theme.fonts.ui ?? ""
            font.pixelSize: Theme.fontSizes.large ?? 0
            font.weight: Theme.fontWeights.bold ?? 0
        }

        Stepper {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            glyph: root.onGlyph

            onStepped: root.shiftMonth(1)
        }
    }

    Column {
        width: parent.width

        Row {
            anchors.horizontalCenter: parent.horizontalCenter

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
            anchors.horizontalCenter: parent.horizontalCenter
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

    QuickSection {
        width: parent.width
        title: "Alarms"

        AlarmEditor {
            id: alarmEditor

            width: parent.width
        }

        PanelEmpty {
            width: parent.width
            visible: Alarms.ordered.length === 0
            text: "No alarms set."
        }

        Repeater {
            model: Alarms.ordered

            AlarmRow {
                required property var modelData

                width: parent.width
                alarm: this.modelData
            }
        }
    }

    QuickSection {
        width: parent.width
        title: "Time zones"

        PanelEmpty {
            width: parent.width
            visible: WorldClocks.chosen.length === 0
            text: "No other time zones shown."
        }

        Repeater {
            model: WorldClocks.chosen

            WorldClockRow {
                required property string modelData

                width: parent.width
                zone: this.modelData
            }
        }

        ZoneField {
            id: zoneField

            width: parent.width
        }
    }
}
