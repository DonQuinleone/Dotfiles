import QtQuick
import Quickshell
import qs.services

PopupWindow {
    id: root

    readonly property real widthFactor: 1.5

    readonly property int panelWidth:
        (Theme.sizes.menuWidth ?? 0) * root.widthFactor
    readonly property int gap: Theme.spacing.tight ?? 0
    readonly property int padding: Theme.sizes.popupPadding ?? 0

    readonly property color tint: Battery.charging
        ? (Theme.palette.good ?? "white")
        : Battery.tintFor(Battery.percent)

    readonly property var readings: [
        {
            label: qsTr("Time left"),
            reading: Battery.spellDuration(Battery.secondsToEmpty),
            shown: Battery.secondsToEmpty > 0
        },
        {
            label: qsTr("Time to full"),
            reading: Battery.spellDuration(Battery.secondsToFull),
            shown: Battery.secondsToFull > 0
        },
        {
            label: qsTr("Full charge"),
            reading: Battery.fullChargeWords,
            shown: Battery.capacityKnown
        },
        {
            label: qsTr("Health"),
            reading: qsTr("%1% of design").arg(Battery.healthPercent),
            shown: Battery.healthKnown
        },
        {
            label: qsTr("Charge cycles"),
            reading: `${Battery.cycleCount}`,
            shown: Battery.cycleCountKnown
        }
    ].filter(entry => entry.shown)

    readonly property string memoryWords: PowerMode.rememberedRows
        .map(row => qsTr("%1 on %2")
            .arg(row.choice.label)
            .arg(row.label))
        .join(qsTr(", "))

    color: Qt.alpha(Theme.palette.bg ?? "black", 0)
    implicitWidth: frame.implicitWidth
    implicitHeight: frame.implicitHeight + root.gap
    visible: false

    onVisibleChanged: if (root.visible) Battery.refresh()

    PopoverGrab {
        surface: root
        shown: root.visible

        onDismissed: root.visible = false
    }

    Rectangle {
        id: frame

        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        implicitWidth: root.panelWidth + root.padding * 2
        implicitHeight: content.implicitHeight + root.padding * 2
        color: Theme.palette.bgAlt ?? "black"
        radius: Theme.radii.large ?? 0
        border.width: Theme.sizes.borderWidth ?? 0
        border.color: Theme.palette.border ?? "transparent"

        Column {
            id: content

            anchors.centerIn: parent
            width: root.panelWidth
            spacing: Theme.spacing.loose ?? 0

            Row {
                spacing: Theme.spacing.normal ?? 0

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: Battery.charging
                        ? Battery.chargingGlyph
                        : Battery.glyphFor(Battery.percent)
                    color: root.tint
                    font.family: Theme.fonts.mono ?? ""
                    font.pixelSize: Theme.sizes.iconNormal ?? 0
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: `${Battery.percent}%`
                    color: root.tint
                    font.family: Theme.fonts.ui ?? ""
                    font.pixelSize: Theme.fontSizes.display ?? 0
                    font.weight: Theme.fontWeights.bold ?? 0
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: Battery.wordsForState(Battery.chargeState)
                    color: Theme.palette.fgDim ?? "white"
                    font.family: Theme.fonts.ui ?? ""
                    font.pixelSize: Theme.fontSizes.normal ?? 0
                }
            }

            Column {
                width: parent.width
                spacing: Theme.spacing.tight ?? 0

                Repeater {
                    model: root.readings

                    PowerReadingRow {
                        required property var modelData

                        width: parent.width
                        label: this.modelData.label
                        reading: this.modelData.reading
                    }
                }
            }

            QuickSection {
                width: parent.width
                visible: PowerMode.available
                title: qsTr("Power profile")

                QuickProfiles {
                    width: parent.width
                }

                Text {
                    width: parent.width
                    visible: root.memoryWords !== ""
                    wrapMode: Text.WordWrap
                    text: qsTr("Remembered: %1.").arg(root.memoryWords)
                    color: Theme.palette.fgDim ?? "white"
                    font.family: Theme.fonts.ui ?? ""
                    font.pixelSize: Theme.fontSizes.small ?? 0
                }
            }
        }
    }
}
