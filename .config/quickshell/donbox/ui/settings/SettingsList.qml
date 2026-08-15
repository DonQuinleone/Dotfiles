import QtQuick
import qs.services

FocusScope {
    id: root

    required property var items

    property int index: 0

    readonly property var keySteps: ({
        [Qt.Key_Up]: -1,
        [Qt.Key_Down]: 1
    })

    readonly property var keyEdges: ({
        [Qt.Key_Home]: "first",
        [Qt.Key_End]: "last"
    })

    signal highlighted(var value)
    signal chosen(var value)

    implicitHeight: Metrics.settingsListHeight
    activeFocusOnTab: true

    function select(wanted: int): void {
        const bounded = Math.max(0,
            Math.min(root.items.length - 1, wanted));
        if (bounded === root.index) return;
        root.index = bounded;
        root.highlighted(root.items[bounded].value);
    }

    function locate(wanted: var): void {
        if (!root.items) return;
        const found = root.items
            .findIndex(item => item.value === wanted);
        if (found < 0) return;
        root.index = found;
    }

    function accept(): void {
        const item = root.items[root.index];
        if (!item) return;
        root.chosen(item.value);
    }

    function handle(event): void {
        const direction = root.keySteps[event.key];
        if (direction !== undefined) {
            root.select(root.index + direction);
            event.accepted = true;
            return;
        }
        const edge = root.keyEdges[event.key];
        if (edge === undefined) return;
        root.select(edge === "first" ? 0 : root.items.length - 1);
        event.accepted = true;
    }

    Keys.onPressed: event => root.handle(event)
    Keys.onReturnPressed: root.accept()
    Keys.onEnterPressed: root.accept()

    ListView {
        id: view

        anchors.fill: parent
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        spacing: Metrics.rowGap
        model: root.items
        currentIndex: root.index
        highlightMoveDuration: Theme.duration("quick")
        preferredHighlightBegin: 0
        preferredHighlightEnd: this.height
        highlightRangeMode: ListView.ApplyRange

        delegate: SettingsListRow {
            required property var modelData
            required property int index

            width: view.width
            item: this.modelData
            selected: this.index === root.index
            focused: root.activeFocus && this.index === root.index

            onActivated: {
                root.forceActiveFocus();
                root.select(this.index);
            }
        }
    }
}
