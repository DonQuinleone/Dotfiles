import QtQuick
import qs.services

FocusScope {
    id: root

    readonly property var keySteps: ({
        [Qt.Key_Up]: -1,
        [Qt.Key_Down]: 1
    })

    readonly property var keyEdges: ({
        [Qt.Key_Home]: 0,
        [Qt.Key_End]: Settings.panes.length - 1
    })

    implicitWidth: Metrics.settingsNavWidth
    activeFocusOnTab: true

    function handle(event): void {
        const direction = root.keySteps[event.key];
        if (direction !== undefined) {
            Settings.step(direction);
            event.accepted = true;
            return;
        }
        const edge = root.keyEdges[event.key];
        if (edge === undefined) return;
        Settings.select(edge);
        event.accepted = true;
    }

    Keys.onPressed: event => root.handle(event)

    Column {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Theme.sizes.popupPadding ?? 0
        spacing: Metrics.rowGap

        Repeater {
            model: Settings.panes

            SettingsNavRow {
                required property var modelData
                required property int index

                width: parent.width
                pane: this.modelData
                selected: this.index === Settings.current
                focused: root.activeFocus
                    && this.index === Settings.current

                onActivated: {
                    root.forceActiveFocus();
                    Settings.select(this.index);
                }
            }
        }
    }
}
