pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property var neutral: ({
        sensitivity: 0.0,
        naturalScroll: false,
        tapToClick: true,
        scrollFactor: 1.0
    })

    readonly property var kinds: [
        { token: "touchpad", word: qsTr("Touchpad") },
        { token: "trackpad", word: qsTr("Trackpad") },
        { token: "trackball", word: qsTr("Trackball") },
        { token: "trackpoint", word: qsTr("Trackpoint") },
        { token: "keyboard", word: qsTr("Keyboard") },
        { token: "mouse", word: qsTr("Mouse") }
    ]

    readonly property string genericKind: qsTr("Pointer")

    property var pointers: []
    property var keyboards: []

    readonly property var saved: Object.keys(
        Preferences.value("devices"))

    readonly property var rows: root.pointers
        .map(device => ({ name: device.name, connected: true,
            scrollFactor: device.scrollFactor }))
        .concat(root.saved
            .filter(name => !root.connected(name))
            .map(name => ({ name: name, connected: false })))

    function connected(name: string): bool {
        return root.pointers.some(device => device.name === name);
    }

    function kind(name: string): string {
        const row = root.kinds.find(
            entry => name.indexOf(entry.token) >= 0);
        return row ? row.word : root.genericKind;
    }

    function brand(name: string): string {
        const word = name.split(/[^a-z]+/i)
            .find(part => part.length >= 2) ?? "";
        return word.charAt(0).toUpperCase() + word.slice(1);
    }

    function title(name: string): string {
        return `${root.brand(name)} ${root.kind(name)}`.trim();
    }

    function value(device: string, name: string): var {
        return Preferences.deviceValue(
            device, name, root.neutral[name]);
    }

    function overridden(device: string, name: string): bool {
        return Preferences.value("devices")[device]?.[name]
            !== undefined;
    }

    function set(device: string, name: string, updated: var): void {
        Preferences.setDevice(device, name, updated);
    }

    function reset(device: string): void {
        Preferences.forgetDevice(device);
    }

    function absorb(payload: string): void {
        try {
            const parsed = JSON.parse(payload);
            root.pointers = parsed.mice ?? [];
            root.keyboards = parsed.keyboards ?? [];
        } catch (error) {
            console.error("ember: hyprctl gave no device list:",
                error);
        }
    }

    function refresh(): void {
        if (probe.running) return;
        probe.running = true;
    }

    Component.onCompleted: root.refresh()

    Process {
        id: probe

        command: ["hyprctl", "-j", "devices"]

        stdout: StdioCollector {
            onStreamFinished: root.absorb(this.text)
        }
    }
}
