import qs.services

ChooserWindow {
    id: root

    active: Picker.shown
    monitor: Picker.monitor
    prompt: Picker.prompt
    count: Picker.matches.length
    planar: Picker.grid
    verticalStep: Picker.grid ? Metrics.gridColumns : 1

    surfaceWidth: Picker.grid
        ? Metrics.gridWidth + Metrics.trackWidth
        : Metrics.surfaceWidth

    contentHeight: Picker.grid
        ? Math.min(Metrics.gridHeight, grid.naturalHeight)
        : Math.min(Metrics.listHeight, list.naturalHeight)

    onQueryChanged: Picker.query = root.query
    onMoved: delta => Picker.move(delta)
    onAccepted: Picker.accept()
    onCancelled: Picker.cancel()

    ChooserList {
        id: list

        anchors.fill: parent
        visible: !Picker.grid
        items: Picker.grid ? [] : Picker.matches
        selected: Picker.selected

        onPicked: index => {
            Picker.selected = index;
            Picker.accept();
        }
    }

    ChooserGrid {
        id: grid

        anchors.fill: parent
        visible: Picker.grid
        items: Picker.grid ? Picker.matches : []
        selected: Picker.selected

        onPicked: index => {
            Picker.selected = index;
            Picker.accept();
        }
    }
}
