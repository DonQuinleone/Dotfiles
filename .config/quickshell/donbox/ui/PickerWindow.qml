import qs.services

ChooserWindow {
    id: root

    readonly property bool aside:
        Picker.themePreview && !Picker.grid

    readonly property int asideWidth: root.aside
        ? Metrics.previewWidth + Metrics.gutter
        : 0

    active: Picker.shown
    monitor: Picker.monitor
    prompt: Picker.prompt
    count: Picker.matches.length
    planar: Picker.grid
    verticalStep: Picker.grid ? Metrics.gridColumns : 1

    surfaceWidth: Picker.grid
        ? Metrics.gridWidth + Metrics.trackWidth
        : Metrics.surfaceWidth + root.asideWidth

    // Beside a preview the surface keeps its full height, so
    // narrowing the search does not shrink the picture with it.
    contentHeight: Picker.grid
        ? Math.min(Metrics.gridHeight, grid.naturalHeight)
        : (root.aside
            ? Metrics.listHeight
            : Math.min(Metrics.listHeight, list.naturalHeight))

    onQueryChanged: Picker.query = root.query
    onMoved: delta => Picker.move(delta)
    onAccepted: Picker.accept()
    onCancelled: Picker.cancel()

    ChooserList {
        id: list

        anchors.fill: parent
        anchors.rightMargin: root.asideWidth
        visible: !Picker.grid
        items: Picker.grid ? [] : Picker.matches
        selected: Picker.selected

        onPicked: index => {
            Picker.selected = index;
            Picker.accept();
        }

        onHovered: index => Picker.selected = index
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

    ThemePreviewCard {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: Metrics.previewWidth
        slug: root.aside ? Picker.highlighted : ""
    }
}
