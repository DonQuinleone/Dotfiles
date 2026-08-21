import QtQuick
import Quickshell.Widgets
import qs.services

Item {
    id: root

    property string name: ""
    property int size: Metrics.rowIcon

    readonly property bool swatch: root.name.startsWith("#")

    implicitWidth: root.size
    implicitHeight: root.size
    visible: root.name !== ""

    Rectangle {
        anchors.fill: parent
        visible: root.swatch
        radius: Theme.radii.round ?? 0
        color: root.swatch ? root.name : "transparent"
        border.width: Theme.sizes.borderWidth ?? 0
        border.color: Theme.palette.border ?? "transparent"
    }

    IconImage {
        anchors.fill: parent
        visible: !root.swatch
        asynchronous: true
        source: Icons.sourceFor(root.name)
    }
}
