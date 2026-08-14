import QtQuick
import qs.services

Item {
    id: root

    required property url source
    required property string label
    required property bool selected
    required property bool current
    required property bool focused

    signal activated

    readonly property string currentWord: qsTr("Current")

    implicitWidth: Metrics.settingsCellWidth
    implicitHeight: Metrics.settingsCellHeight

    SettingsSurface {
        anchors.fill: parent
        anchors.margins: Metrics.rowGap
        highlighted: root.selected
        focused: root.focused
        hovered: area.containsMouse

        Image {
            id: preview

            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: Theme.sizes.borderWidth ?? 0
            height: Metrics.settingsThumbnailHeight
            fillMode: Image.PreserveAspectCrop
            sourceSize.width: Metrics.settingsThumbnailWidth
            asynchronous: true
            clip: true
            source: root.source
        }

        Text {
            anchors.top: preview.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: Theme.spacing.hair ?? 0
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideMiddle
            text: root.current
                ? `${root.label} (${root.currentWord})`
                : root.label
            color: root.selected
                ? Theme.onAccent
                : (Theme.palette.fg ?? "white")
            font.family: Theme.fonts.ui ?? ""
            font.pixelSize: Theme.fontSizes.normal ?? 0
            font.weight: root.current
                ? (Theme.fontWeights.bold ?? 0)
                : (Theme.fontWeights.regular ?? 0)
        }
    }

    MouseArea {
        id: area

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: root.activated()
    }
}
