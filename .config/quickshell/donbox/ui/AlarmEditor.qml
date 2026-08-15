import QtQuick
import qs.services

Row {
    id: root

    property int hour: 7
    property int minute: 0

    readonly property string backGlyph: "‹"
    readonly property string onGlyph: "›"

    spacing: Theme.spacing.hair ?? 0

    function shiftHour(delta: int): void {
        root.hour = (root.hour + delta + Alarms.hoursPerDay)
            % Alarms.hoursPerDay;
    }

    function shiftMinute(delta: int): void {
        root.minute = (root.minute + delta + Alarms.minutesPerHour)
            % Alarms.minutesPerHour;
    }

    component Reading: Text {
        anchors.verticalCenter: parent?.verticalCenter ?? undefined
        horizontalAlignment: Text.AlignHCenter
        color: Theme.palette.fg ?? "white"
        font.family: Theme.fonts.mono ?? ""
        font.pixelSize: Theme.fontSizes.display ?? 0
        font.weight: Theme.fontWeights.bold ?? 0
        font.features: ({ "tnum": 1 })
    }

    Stepper {
        glyph: root.backGlyph

        onStepped: root.shiftHour(-1)
    }

    Reading {
        text: Alarms.padded(root.hour)
    }

    Stepper {
        glyph: root.onGlyph

        onStepped: root.shiftHour(1)
    }

    Reading {
        text: ":"
    }

    Stepper {
        glyph: root.backGlyph

        onStepped: root.shiftMinute(-Alarms.minuteStep)
    }

    Reading {
        text: Alarms.padded(root.minute)
    }

    Stepper {
        glyph: root.onGlyph

        onStepped: root.shiftMinute(Alarms.minuteStep)
    }

    QuickChip {
        anchors.verticalCenter: parent.verticalCenter
        label: "Add"
        glyph: Alarms.glyph

        onActivated: Alarms.add(root.hour, root.minute)
    }
}
