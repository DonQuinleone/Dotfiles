import QtQuick
import Quickshell
import qs.services

Rectangle {
    id: root

    required property QsMenuEntry entry
    required property int depth

    signal triggered

    readonly property bool separator: root.entry.isSeparator
    readonly property int indent: (Theme.sizes.popupPadding ?? 0)
        + root.depth * (Theme.spacing.section ?? 0)

    width: parent?.width ?? 0
    height: root.separator
        ? (Theme.spacing.normal ?? 0)
        : (Theme.sizes.hitTarget ?? 0)
    color: area.containsMouse
        ? (Theme.palette.surface ?? "transparent")
        : Qt.alpha(Theme.palette.surface ?? "black", 0)

    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: Theme.sizes.popupPadding ?? 0
        anchors.rightMargin: Theme.sizes.popupPadding ?? 0
        height: Theme.sizes.borderWidth ?? 0
        color: Theme.palette.border ?? "transparent"
        visible: root.separator
    }

    Text {
        anchors.left: parent.left
        anchors.right: chevron.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: root.indent
        anchors.rightMargin: Theme.spacing.tight ?? 0
        visible: !root.separator
        elide: Text.ElideRight
        text: root.entry.text
        color: root.entry.enabled
            ? (Theme.palette.fg ?? "white")
            : (Theme.palette.fgDim ?? "white")
        font.family: Theme.fonts.ui ?? ""
        font.pixelSize: Theme.fontSizes.normal ?? 0
        font.weight: Theme.fontWeights.regular ?? 0
    }

    Text {
        id: chevron

        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: Theme.sizes.popupPadding ?? 0
        visible: root.entry.hasChildren
            || root.entry.checkState === Qt.Checked
        text: root.entry.hasChildren ? "›" : "✓"
        color: Theme.palette.accentSoft ?? "white"
        font.family: Theme.fonts.ui ?? ""
        font.pixelSize: Theme.fontSizes.large ?? 0
        font.weight: Theme.fontWeights.bold ?? 0
    }

    MouseArea {
        id: area

        anchors.fill: parent
        hoverEnabled: true
        enabled: !root.separator && root.entry.enabled
        cursorShape: Qt.PointingHandCursor

        onClicked: root.triggered()
    }
}
