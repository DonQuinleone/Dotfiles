pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    readonly property real quietest: 0.0
    readonly property real unityGain: 1.0
    readonly property real loudest: 1.5

    // Pipewire calls an application's playback stream a sink,
    // so the streams worth mixing are the ones that are both.
    readonly property var playing: Pipewire.nodes.values.filter(
        node => node.audio && node.isStream && node.isSink)

    function label(node: var): string {
        const owner = node.properties["application.name"];
        return owner || node.description || node.name;
    }

    function detail(node: var): string {
        const title = node.properties["media.name"] ?? "";
        return title === root.label(node) ? "" : title;
    }

    function volume(node: var): real {
        return node?.audio?.volume ?? 0;
    }

    function muted(node: var): bool {
        return node?.audio?.muted ?? false;
    }

    function setVolume(node: var, wanted: real): void {
        if (!node?.audio) return;
        node.audio.volume = Math.max(root.quietest,
            Math.min(root.loudest, wanted));
    }

    function toggleMute(node: var): void {
        if (!node?.audio) return;
        node.audio.muted = !node.audio.muted;
    }

    PwObjectTracker {
        objects: root.playing
    }
}
