import QtQuick
import Quickshell
import qs.services

Item {
    id: root

    property bool interactive: true

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
            visible: Caffeine.active
            text: Caffeine.glyph
            color: Theme.palette.accent ?? "white"
            font.pixelSize: Theme.sizes.iconNormal ?? 0
        }

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

        PillText {
            visible: Caffeine.active
            text: Caffeine.glyph
            color: Theme.palette.accent ?? "white"
            font.pixelSize: Theme.sizes.iconNormal ?? 0
        }
    }

    PanelToggle {
        surface: dropdown
        enabled: root.interactive
        visible: root.interactive
    }

    ClockPopup {
        id: dropdown

        name: "clock"
        allowed: root.interactive

        today: clock.date
        under: root
    }
}
