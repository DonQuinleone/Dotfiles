pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    readonly property string outputKind: "output"
    readonly property string inputKind: "input"

    readonly property real quietest: 0.0
    readonly property real loudest: 1.0

    readonly property int noDevice: -1

    readonly property PwNode output: Pipewire.defaultAudioSink
    readonly property PwNode input: Pipewire.defaultAudioSource

    function wantsSink(kind: string): bool {
        return kind === root.outputKind;
    }

    function inUse(kind: string): var {
        return root.wantsSink(kind) ? root.output : root.input;
    }

    function present(kind: string): bool {
        return root.inUse(kind) !== null;
    }

    function devices(kind: string): var {
        const sinks = root.wantsSink(kind);
        return Pipewire.nodes.values.filter(node => node.audio
            && !node.isStream && node.isSink === sinks);
    }

    function label(node: var): string {
        return node.description || node.nickname || node.name;
    }

    function rows(kind: string): var {
        const chosen = root.inUse(kind)?.id ?? root.noDevice;
        return root.devices(kind)
            .map(node => ({
                value: node.id,
                label: root.label(node),
                detail: node.nickname || node.name,
                current: node.id === chosen
            }))
            .sort((one, other) =>
                one.label.localeCompare(other.label));
    }

    function volume(kind: string): real {
        return root.inUse(kind)?.audio?.volume ?? 0;
    }

    function muted(kind: string): bool {
        return root.inUse(kind)?.audio?.muted ?? false;
    }

    function setVolume(kind: string, wanted: real): void {
        const node = root.inUse(kind);
        if (!node?.audio) return;
        node.audio.volume = Math.max(root.quietest,
            Math.min(root.loudest, wanted));
    }

    function toggleMute(kind: string): void {
        const node = root.inUse(kind);
        if (!node?.audio) return;
        node.audio.muted = !node.audio.muted;
    }

    function use(kind: string, id: int): void {
        const node = root.devices(kind)
            .find(device => device.id === id);
        if (!node) return;
        if (root.wantsSink(kind)) {
            Pipewire.preferredDefaultAudioSink = node;
            return;
        }
        Pipewire.preferredDefaultAudioSource = node;
    }

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink,
            Pipewire.defaultAudioSource]
    }
}
