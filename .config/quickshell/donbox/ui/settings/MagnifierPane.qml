import QtQuick
import qs.services

Column {
    id: root

    readonly property real zoomStepMinimum: 0.1
    readonly property real zoomStepMaximum: 2.0
    readonly property real zoomStepIncrement: 0.1
    readonly property int zoomStepDigits: 1

    readonly property int cursorMinimum: 24
    readonly property int cursorMaximum: 128
    readonly property int cursorIncrement: 8

    readonly property int borderMinimum: 0
    readonly property int borderMaximum: 16
    readonly property int borderIncrement: 1

    readonly property var cameraOptions: [
        { value: false, label: qsTr("Follows the cursor") },
        { value: true, label: qsTr("Holds until the edge") }
    ]

    spacing: Theme.spacing.loose ?? 0

    SettingsCard {
        width: parent.width
        title: qsTr("Magnifier")

        SettingsRow {
            width: parent.width
            label: qsTr("Zoom step")
            hint: qsTr("How far Super and = or - move the zoom.")

            SettingsStepper {
                width: parent.width
                value: Preferences.value("zoomStep")
                minimum: root.zoomStepMinimum
                maximum: root.zoomStepMaximum
                step: root.zoomStepIncrement
                readout: `${this.value.toFixed(root.zoomStepDigits)}×`

                onMoved: wanted =>
                    Preferences.set("zoomStep", wanted)
            }
        }

        SettingsRow {
            width: parent.width
            label: qsTr("Zoomed view")
            hint: qsTr("A held view stays still until the pointer "
                + "reaches the edge of the screen.")

            SettingsChoice {
                width: parent.width
                options: root.cameraOptions
                current: Preferences.value("detachedCamera")

                onChosen: wanted =>
                    Preferences.set("detachedCamera", wanted)
            }
        }

        SettingsRow {
            width: parent.width
            label: qsTr("Follow the text cursor")
            hint: qsTr("Moves the zoomed view to the caret as you "
                + "type, which needs the view to follow the cursor.")

            SettingsToggle {
                width: parent.width
                checked: Accessibility.caretFollow

                onActivated: Accessibility.setCaretFollow(
                    !Accessibility.caretFollow)
            }
        }
    }

    SettingsCard {
        width: parent.width
        title: qsTr("Pointer and focus")

        SettingsRow {
            width: parent.width
            label: qsTr("Cursor size")
            hint: qsTr("Applications started before the change keep "
                + "the old size.")

            SettingsStepper {
                width: parent.width
                value: Preferences.value("cursorSize")
                minimum: root.cursorMinimum
                maximum: root.cursorMaximum
                step: root.cursorIncrement
                readout: qsTr("%1 pixels").arg(this.value)

                onMoved: wanted =>
                    Accessibility.setCursorSize(wanted)
            }
        }

        SettingsRow {
            width: parent.width
            label: qsTr("Focused window border")
            hint: qsTr("A thicker border makes the focused window "
                + "easier to find under magnification.")

            SettingsStepper {
                width: parent.width
                value: Preferences.value("borderSize")
                minimum: root.borderMinimum
                maximum: root.borderMaximum
                step: root.borderIncrement
                readout: qsTr("%1 pixels").arg(this.value)

                onMoved: wanted =>
                    Preferences.set("borderSize", wanted)
            }
        }
    }
}
