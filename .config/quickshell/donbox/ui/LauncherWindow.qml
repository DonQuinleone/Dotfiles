import qs.services

ChooserWindow {
    id: root

    active: Launcher.shown
    monitor: Launcher.monitor
    prompt: qsTr("Run")
    emptyText: qsTr("No applications match")
    count: Launcher.matches.length
    contentHeight: Math.min(Metrics.listHeight, list.naturalHeight)

    onQueryChanged: Launcher.query = root.query
    onMoved: delta => Launcher.move(delta)
    onAccepted: Launcher.accept()
    onCancelled: Launcher.hide()

    ChooserList {
        id: list

        anchors.fill: parent
        items: Launcher.matches
        selected: Launcher.selected

        onPicked: index => {
            Launcher.selected = index;
            Launcher.accept();
        }
    }
}
