import QtQuick
import qs.services

SettingsSurface {
    id: root

    required property string label

    property string glyph: ""
    property bool selected: false
    property bool focusable: true

    signal activated

    implicitWidth: layout.implicitWidth
        + (Theme.sizes.popupPadding ?? 0) * 2
    activeFocusOnTab: root.focusable
    focused: root.activeFocus
    highlighted: root.selected
    hovered: area.containsMouse

    Keys.onReturnPressed: root.activated()
    Keys.onEnterPressed: root.activated()
    Keys.onSpacePressed: root.activated()

    Row {
        id: layout

        anchors.centerIn: parent
        spacing: Theme.spacing.tight ?? 0

        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.glyph !== ""
            text: root.glyph
            color: root.ink
            font.family: Theme.fonts.mono ?? ""
            font.pixelSize: Theme.sizes.iconNormal ?? 0
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.label
            color: root.ink
            font.family: Theme.fonts.ui ?? ""
            font.pixelSize: Theme.fontSizes.normal ?? 0
            font.weight: Theme.fontWeights.medium ?? 0
        }
    }

    MouseArea {
        id: area

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            root.forceActiveFocus();
            root.activated();
        }
    }
}
