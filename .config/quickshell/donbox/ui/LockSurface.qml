import QtQuick
import QtQuick.Effects
import qs.services

Item {
    id: root

    readonly property real blurStrength: 1.0
    readonly property int blurRadius: 64
    readonly property real rainOpacity: 0.16

    readonly property var printable: /^[^\x00-\x1f\x7f]+$/

    readonly property var bindings: [
        { key: Qt.Key_Return,      action: "submit" },
        { key: Qt.Key_Enter,       action: "submit" },
        { key: Qt.Key_Backspace,   action: "erase"  },
        { key: Qt.Key_Escape,      action: "clear"  },
        { key: Qt.Key_U,           action: "clear",  ctrl: true },
        { key: Qt.Key_W,           action: "clear",  ctrl: true },
        { key: Qt.Key_H,           action: "erase",  ctrl: true }
    ]

    readonly property var actions: ({
        "submit": () => Lock.submit(),
        "erase": () => Lock.erase(),
        "clear": () => Lock.clear()
    })

    focus: true

    Keys.onPressed: event => root.handle(event)

    function matches(binding, event): bool {
        if (binding.key !== event.key) return false;
        return (binding.ctrl ?? false)
            === ((event.modifiers & Qt.ControlModifier) !== 0);
    }

    function handle(event): void {
        event.accepted = true;
        for (const binding of root.bindings) {
            if (!root.matches(binding, event)) continue;
            root.actions[binding.action]();
            return;
        }
        if (event.modifiers & Qt.ControlModifier) return;
        if (!root.printable.test(event.text)) return;
        Lock.append(event.text);
    }

    Image {
        id: scene

        anchors.fill: parent
        source: Theme.wallpaper
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: false
        visible: false
        layer.enabled: true
    }

    MultiEffect {
        anchors.fill: parent
        source: scene
        blurEnabled: true
        blur: root.blurStrength
        blurMax: root.blurRadius
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.palette.bg ?? "black"
        opacity: Theme.opacities.dim ?? 1
    }

    CrtRain {
        anchors.fill: parent
        opacity: root.rainOpacity
    }

    CrtScanlines {
        anchors.fill: parent
    }

    LockPanel {
        anchors.centerIn: parent
    }
}
