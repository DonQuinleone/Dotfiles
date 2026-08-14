import QtQuick
import qs.services

Item {
    id: root

    property string prompt: ""
    property alias text: input.text
    property bool planar: false
    property int verticalStep: 1

    signal moved(int delta)
    signal accepted
    signal cancelled

    readonly property var bindings: [
        { key: Qt.Key_Escape,      action: "cancel"   },
        { key: Qt.Key_Return,      action: "accept"   },
        { key: Qt.Key_Enter,       action: "accept"   },
        { key: Qt.Key_Down,        action: "forward"  },
        { key: Qt.Key_Up,          action: "backward" },
        { key: Qt.Key_N,           action: "forward",  ctrl: true },
        { key: Qt.Key_P,           action: "backward", ctrl: true },
        { key: Qt.Key_J,           action: "forward",  ctrl: true },
        { key: Qt.Key_K,           action: "backward", ctrl: true },
        { key: Qt.Key_BracketLeft, action: "cancel",   ctrl: true },
        { key: Qt.Key_Right,       action: "next",     planar: true },
        { key: Qt.Key_Left,        action: "previous", planar: true }
    ]

    readonly property var deltas: ({
        "next": 1,
        "previous": -1,
        "forward": root.verticalStep,
        "backward": -root.verticalStep
    })

    implicitHeight: Metrics.rowHeight

    function begin(): void {
        input.text = "";
        input.forceActiveFocus();
    }

    function dispatch(action: string): void {
        if (action === "cancel") {
            root.cancelled();
            return;
        }
        if (action === "accept") {
            root.accepted();
            return;
        }
        root.moved(root.deltas[action]);
    }

    function matches(binding, event): bool {
        if (binding.key !== event.key) return false;
        if ((binding.planar ?? false) && !root.planar) return false;
        return (binding.ctrl ?? false)
            === ((event.modifiers & Qt.ControlModifier) !== 0);
    }

    function handle(event): void {
        for (const binding of root.bindings) {
            if (!root.matches(binding, event)) continue;
            root.dispatch(binding.action);
            event.accepted = true;
            return;
        }
    }

    Text {
        id: label

        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        visible: root.prompt !== ""
        text: root.prompt
        color: Theme.palette.accent ?? "white"
        font.family: Theme.fonts.ui ?? ""
        font.pixelSize: Theme.fontSizes.display ?? 0
        font.weight: Theme.fontWeights.bold ?? 0
    }

    TextInput {
        id: input

        anchors.left: label.visible ? label.right : parent.left
        anchors.leftMargin: label.visible ? Metrics.gutter : 0
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        clip: true
        color: Theme.palette.fg ?? "white"
        selectionColor: Theme.palette.accent ?? "white"
        selectedTextColor: Theme.palette.bg ?? "black"
        font.family: Theme.fonts.ui ?? ""
        font.pixelSize: Theme.fontSizes.display ?? 0
        font.weight: Theme.fontWeights.medium ?? 0

        Keys.onPressed: event => root.handle(event)
    }
}
