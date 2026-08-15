import QtQuick
import Quickshell.Hyprland
import qs.services

SettingsCard {
    id: root

    required property var monitor

    readonly property real labelWidthShare: 0.42
    readonly property int scaleDigits: 2
    readonly property int refreshDigits: 2

    readonly property real refreshRate:
        root.monitor.lastIpcObject?.refreshRate ?? 0

    readonly property bool focused:
        Hyprland.focusedMonitor?.name === root.monitor.name

    readonly property var workspaceNumbers: Hyprland.workspaces.values
        .filter(workspace => workspace.id > 0
            && workspace.monitor?.name === root.monitor.name)
        .map(workspace => workspace.id)
        .sort((left, right) => left - right)

    readonly property string resolution: qsTr("%1 × %2")
        .arg(root.monitor.width).arg(root.monitor.height)

    readonly property string mode: root.refreshRate > 0
        ? qsTr("%1 at %2 Hz").arg(root.resolution)
            .arg(root.refreshRate.toFixed(root.refreshDigits))
        : root.resolution

    readonly property string scaleReading:
        `${root.monitor.scale.toFixed(root.scaleDigits)}×`

    readonly property string corner: qsTr("%1, %2")
        .arg(root.monitor.x).arg(root.monitor.y)

    readonly property string workspaceList:
        root.workspaceNumbers.length > 0
            ? root.workspaceNumbers.join(", ")
            : qsTr("None")

    readonly property string showing:
        root.monitor.activeWorkspace?.name || qsTr("None")

    readonly property var facts: [
        { label: qsTr("Mode"), reading: root.mode },
        { label: qsTr("Scale"), reading: root.scaleReading },
        { label: qsTr("Top left corner"), reading: root.corner },
        { label: qsTr("Focused"),
          reading: root.focused ? qsTr("Yes") : qsTr("No") },
        { label: qsTr("Workspaces here"),
          reading: root.workspaceList },
        { label: qsTr("Showing now"), reading: root.showing }
    ]

    title: root.monitor.name

    SettingsNote {
        width: parent.width
        text: root.monitor.description
    }

    Column {
        width: parent.width
        spacing: Theme.spacing.tight ?? 0

        Repeater {
            model: root.facts

            Item {
                id: fact

                required property var modelData

                width: parent.width
                height: Math.max(factLabel.contentHeight,
                    factReading.contentHeight)

                Text {
                    id: factLabel

                    anchors.left: parent.left
                    anchors.top: parent.top
                    width: parent.width * root.labelWidthShare
                    wrapMode: Text.WordWrap
                    text: fact.modelData.label
                    color: Theme.palette.fgDim ?? "white"
                    font.family: Theme.fonts.ui ?? ""
                    font.pixelSize: Theme.fontSizes.normal ?? 0
                }

                Text {
                    id: factReading

                    anchors.left: factLabel.right
                    anchors.right: parent.right
                    anchors.top: parent.top
                    horizontalAlignment: Text.AlignRight
                    wrapMode: Text.WordWrap
                    text: fact.modelData.reading
                    color: Theme.palette.fg ?? "white"
                    font.family: Theme.fonts.mono ?? ""
                    font.pixelSize: Theme.fontSizes.normal ?? 0
                }
            }
        }
    }
}
