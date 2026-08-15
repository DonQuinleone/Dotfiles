import QtQuick
import qs.services

Rectangle {
    id: root

    required property string label
    required property bool current

    readonly property string currentGlyph: "󰄬"
    readonly property int gap: Theme.spacing.tight ?? 0

    readonly property var activateKeys:
        [Qt.Key_Return, Qt.Key_Enter, Qt.Key_Space]

    readonly property color edge: {
        if (area.containsMouse || root.activeFocus)
            return Theme.palette.fg ?? "transparent";
        if (root.current) return Theme.palette.accent ?? "transparent";
        return Theme.palette.border ?? "transparent";
    }

    signal chosen

    implicitHeight: Theme.sizes.hitTarget ?? 0
    activeFocusOnTab: true
    radius: Theme.radii.normal ?? 0
    color: root.current
        ? (Theme.palette.surface ?? "transparent")
        : (Theme.palette.bgAlt ?? "transparent")
    border.width: Theme.sizes.borderWidth ?? 0
    border.color: root.edge

    Keys.onPressed: event => {
        if (!root.activateKeys.includes(event.key)) return;
        root.chosen();
        event.accepted = true;
    }

    Text {
        id: tick

        anchors.left: parent.left
        anchors.leftMargin: root.gap
        anchors.verticalCenter: parent.verticalCenter
        width: Theme.sizes.iconNormal ?? 0
        text: root.current ? root.currentGlyph : ""
        color: Theme.palette.accent ?? "white"
        font.family: Theme.fonts.mono ?? ""
        font.pixelSize: Theme.sizes.iconNormal ?? 0
    }

    Text {
        anchors.left: tick.right
        anchors.leftMargin: root.gap
        anchors.right: parent.right
        anchors.rightMargin: root.gap
        anchors.verticalCenter: parent.verticalCenter
        elide: Text.ElideMiddle
        text: root.label
        color: root.current
            ? (Theme.palette.accent ?? "white")
            : (Theme.palette.fg ?? "white")
        font.family: Theme.fonts.ui ?? ""
        font.pixelSize: Theme.fontSizes.normal ?? 0
        font.weight: root.current
            ? (Theme.fontWeights.bold ?? 0)
            : (Theme.fontWeights.regular ?? 0)
    }

    MouseArea {
        id: area

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: root.chosen()
    }
}
