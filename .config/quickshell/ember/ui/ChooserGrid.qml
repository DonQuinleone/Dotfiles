import QtQuick
import qs.services

Item {
    id: root

    required property var items
    required property int selected

    signal picked(int index)

    readonly property int naturalHeight: Metrics.cellHeight
        * Math.ceil(root.items.length / Metrics.gridColumns)

    GridView {
        id: view

        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.rightMargin: Metrics.trackWidth
        clip: true
        cellWidth: Metrics.cellWidth
        cellHeight: Metrics.cellHeight
        model: root.items
        currentIndex: root.selected
        boundsBehavior: Flickable.StopAtBounds

        onCurrentIndexChanged: this.positionViewAtIndex(
            this.currentIndex, GridView.Contain)

        delegate: ChooserCell {
            required property var modelData
            required property int index

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
