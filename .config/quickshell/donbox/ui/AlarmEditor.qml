import QtQuick
import qs.services

Column {
    id: root

    readonly property var quickMinutes: [5, 15, 30, 60]
    readonly property int pad: Theme.sizes.popupPadding ?? 0

    spacing: Theme.spacing.tight ?? 0

    function reset(): void {
        const now = new Date();
        input.text =
            Alarms.clockOf(now.getHours(), now.getMinutes());
    }

    function submit(): void {
        const parsed = Alarms.parse(input.text);
        if (parsed === null) return;
        Alarms.add(parsed.hour, parsed.minute);
        root.reset();
    }

    Component.onCompleted: root.reset()

    Row {
        spacing: Theme.spacing.tight ?? 0

        Rectangle {
            width: metrics.advanceWidth + root.pad * 2
            height: Theme.sizes.hitTarget ?? 0
            radius: Theme.radii.normal ?? 0
            color: Theme.palette.surface ?? "transparent"
            border.width: Theme.sizes.borderWidth ?? 0
            border.color: input.activeFocus
                ? (Theme.palette.accent ?? "transparent")
                : (Theme.palette.border ?? "transparent")

            TextMetrics {
                id: metrics

                font: input.font
                text: "+00:00"
            }

            TextInput {
                id: input

                anchors.fill: parent
                anchors.leftMargin: root.pad
                anchors.rightMargin: root.pad
                verticalAlignment: TextInput.AlignVCenter
                horizontalAlignment: TextInput.AlignHCenter
                color: Alarms.parse(this.text)
                    ? (Theme.palette.fg ?? "white")
                    : (Theme.palette.bad ?? "white")
                selectionColor: Theme.palette.accent ?? "white"
                selectedTextColor: Theme.onAccent
                font.family: Theme.fonts.mono ?? ""
                font.pixelSize: Theme.fontSizes.large ?? 0
                font.weight: Theme.fontWeights.bold ?? 0
                font.features: ({ "tnum": 1 })
                clip: true

                Keys.onReturnPressed: root.submit()
                Keys.onEnterPressed: root.submit()
            }
        }

        QuickChip {
            anchors.verticalCenter: parent.verticalCenter
            label: "Add"
            glyph: Alarms.glyph

            onActivated: root.submit()
        }
    }

    Row {
        spacing: Theme.spacing.tight ?? 0

        Repeater {
            model: root.quickMinutes

            QuickChip {
                required property int modelData

                label: `+${this.modelData}`

                onActivated: Alarms.addRelative(this.modelData)
            }
        }
    }
}
