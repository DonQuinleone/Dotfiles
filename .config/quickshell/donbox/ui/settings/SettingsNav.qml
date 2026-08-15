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

    readonly property int padding: Theme.sizes.popupPadding ?? 0

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

    // The pane list outgrew the window once it passed ten
    // entries, and a selection moved by the keyboard is worth
    // nothing if it lands somewhere the eye cannot reach.
    function reveal(): void {
        const item = rows.itemAt(Settings.current);
        if (!item) return;
        const top = list.y + item.y;
        if (top < scroller.contentY) {
            scroller.contentY = Math.max(0, top - root.padding);
            return;
        }
        const bottom = top + item.height;
        if (bottom <= scroller.contentY + scroller.height) return;
        scroller.contentY = Math.min(
            Math.max(0, scroller.contentHeight - scroller.height),
            bottom - scroller.height + root.padding);
    }

    Keys.onPressed: event => root.handle(event)

    Connections {
        target: Settings

        function onCurrentChanged(): void {
            root.reveal();
        }
    }

    Flickable {
        id: scroller

        anchors.fill: parent
        contentWidth: root.width
        contentHeight: list.implicitHeight + root.padding * 2
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        Column {
            id: list

            x: root.padding
            y: root.padding
            width: root.width - root.padding * 2
            spacing: Metrics.rowGap

            Repeater {
                id: rows

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
}
