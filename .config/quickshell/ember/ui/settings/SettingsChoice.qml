import QtQuick
import qs.services

FocusScope {
    id: root

    required property var options
    required property var current

    signal chosen(var wanted)

    readonly property int index: root.options
        .findIndex(option => option.value === root.current)

    readonly property var keySteps: ({
        [Qt.Key_Left]: -1,
        [Qt.Key_Up]: -1,
        [Qt.Key_Right]: 1,
        [Qt.Key_Down]: 1
    })

    implicitHeight: flow.implicitHeight
    activeFocusOnTab: true

    function step(delta: int): void {
        const wanted = Math.max(0,
            Math.min(root.options.length - 1, root.index + delta));
        root.chosen(root.options[wanted].value);
    }

    Keys.onPressed: event => {
        const direction = root.keySteps[event.key];
        if (direction === undefined) return;
        root.step(direction);
        event.accepted = true;
    }

    Flow {
        id: flow

        width: parent.width
        spacing: Theme.spacing.tight ?? 0

        Repeater {
            model: root.options

            SettingsButton {
                required property var modelData

                focusable: false
                label: this.modelData.label
                glyph: this.modelData.glyph ?? ""
                selected: this.modelData.value === root.current
                focused: root.activeFocus && this.selected

                onActivated: {
                    root.forceActiveFocus();
                    root.chosen(this.modelData.value);
                }
            }
        }
    }
}
