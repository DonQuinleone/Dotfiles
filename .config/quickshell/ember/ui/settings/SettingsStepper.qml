import QtQuick
import qs.services

Item {
    id: root

    required property real value
    required property string readout
    required property real minimum
    required property real maximum
    required property real step

    property real largeStep: root.step * root.leapFactor
    property string lessWord: qsTr("Less")
    property string moreWord: qsTr("More")

    readonly property int leapFactor: 5
    readonly property string lessGlyph: "󰍷"
    readonly property string moreGlyph: "󰐕"

    readonly property var keySteps: ({
        [Qt.Key_Left]: -1,
        [Qt.Key_Down]: -1,
        [Qt.Key_Minus]: -1,
        [Qt.Key_Right]: 1,
        [Qt.Key_Up]: 1,
        [Qt.Key_Plus]: 1,
        [Qt.Key_Equal]: 1
    })

    readonly property var keyLeaps: ({
        [Qt.Key_PageDown]: -1,
        [Qt.Key_PageUp]: 1
    })

    readonly property var keyEdges: ({
        [Qt.Key_Home]: "minimum",
        [Qt.Key_End]: "maximum"
    })

    signal moved(real wanted)

    implicitHeight: Metrics.rowHeight

    function settle(wanted: real): void {
        root.moved(Math.max(root.minimum,
            Math.min(root.maximum, wanted)));
    }

    function nudge(delta: real): void {
        root.settle(root.value + delta);
    }

    function handle(event): void {
        const direction = root.keySteps[event.key];
        if (direction !== undefined) {
            root.nudge(direction * root.step);
            event.accepted = true;
            return;
        }
        const leap = root.keyLeaps[event.key];
        if (leap !== undefined) {
            root.nudge(leap * root.largeStep);
            event.accepted = true;
            return;
        }
        const edge = root.keyEdges[event.key];
        if (edge === undefined) return;
        root.settle(root[edge]);
        event.accepted = true;
    }

    function focusValue(): void {
        display.forceActiveFocus();
    }

    SettingsButton {
        id: less

        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        focusable: false
        label: root.lessWord
        glyph: root.lessGlyph

        onActivated: {
            display.forceActiveFocus();
            root.nudge(-root.step);
        }
    }

    SettingsSurface {
        id: display

        anchors.left: less.right
        anchors.right: more.left
        anchors.leftMargin: Theme.spacing.tight ?? 0
        anchors.rightMargin: Theme.spacing.tight ?? 0
        anchors.verticalCenter: parent.verticalCenter
        activeFocusOnTab: true
        focused: this.activeFocus

        Keys.onPressed: event => root.handle(event)

        Text {
            anchors.centerIn: parent
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            text: root.readout
            color: Theme.palette.fg ?? "white"
            font.family: Theme.fonts.mono ?? ""
            font.pixelSize: Theme.fontSizes.large ?? 0
            font.weight: Theme.fontWeights.bold ?? 0
            font.features: ({ "tnum": 1 })
        }
    }

    SettingsButton {
        id: more

        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        focusable: false
        label: root.moreWord
        glyph: root.moreGlyph

        onActivated: {
            display.forceActiveFocus();
            root.nudge(root.step);
        }
    }
}
