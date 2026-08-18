import QtQuick
import qs.services

Column {
    id: root

    readonly property var quickMinutes: [5, 15, 30, 60]

    spacing: Theme.spacing.tight ?? 0

    function reset(): void {
        const now = new Date();
        field.text =
            Alarms.clockOf(now.getHours(), now.getMinutes());
    }

    function submit(): void {
        const parsed = Alarms.parse(field.text);
        if (parsed === null) return;
        Alarms.add(parsed.hour, parsed.minute);
        root.reset();
    }

    Component.onCompleted: root.reset()

    Row {
        spacing: Theme.spacing.tight ?? 0

        TextField {
            id: field

            anchors.verticalCenter: parent.verticalCenter
            sample: "+00:00"
            horizontalAlignment: TextInput.AlignHCenter
            valid: Alarms.parse(this.text) !== null
            font.family: Theme.fonts.mono ?? ""
            font.pixelSize: Theme.fontSizes.large ?? 0
            font.weight: Theme.fontWeights.bold ?? 0
            font.features: ({ "tnum": 1 })

            onAccepted: root.submit()
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
