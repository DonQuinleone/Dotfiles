import QtQuick
import qs.services

Item {
    id: root

    required property var items
    required property int selected

    signal picked(int index)

    readonly property int naturalHeight:
        root.items.length * (Metrics.rowHeight + Metrics.rowGap)

    ListView {
        id: view

        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.rightMargin: Metrics.trackWidth
        clip: true
        model: root.items
        currentIndex: root.selected
        spacing: Metrics.rowGap
        boundsBehavior: Flickable.StopAtBounds

        onCurrentIndexChanged: this.positionViewAtIndex(
            this.currentIndex, ListView.Contain)

        delegate: ChooserRow {
            required property var modelData
            required property int index

            width: view.width
            item: this.modelData
            selected: this.index === root.selected

            onActivated: root.picked(this.index)
        }
    }

    ChooserScrollBar {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        view: view
    }
}
