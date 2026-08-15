pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property var panes: [
        { slug: "appearance", title: qsTr("Appearance"), glyph: "󰸌" },
        { slug: "magnifier", title: qsTr("Magnifier"), glyph: "󰍉" },
        { slug: "monitors", title: qsTr("Monitors and workspaces"),
          glyph: "󰍺" },
        { slug: "audio", title: qsTr("Audio"), glyph: "󰕾" },
        { slug: "bluetooth", title: qsTr("Bluetooth"), glyph: "󰂯" },
        { slug: "notifications", title: qsTr("Notifications"),
          glyph: "󰂚" },
        { slug: "devices", title: qsTr("Input devices"), glyph: "󰍽" },
        { slug: "bindings", title: qsTr("Shortcuts"), glyph: "󰌌" }
    ]

    property bool shown: false
    property int current: 0

    readonly property string pane: root.panes[root.current].slug

    function select(index: int): void {
        root.current = Math.max(0,
            Math.min(root.panes.length - 1, index));
    }

    function step(delta: int): void {
        root.select(root.current + delta);
    }

    function show(): void {
        root.shown = true;
    }

    function reveal(slug: string): void {
        const found = root.panes
            .findIndex(pane => pane.slug === slug);
        if (found < 0) return;
        root.current = found;
        root.shown = true;
    }

    function hide(): void {
        root.shown = false;
    }

    function toggle(): void {
        root.shown = !root.shown;
    }
}
