pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

Singleton {
    id: root

    readonly property int dwellMs: 1600
    readonly property int settleMs: 700
    readonly property string backlight:
        "/sys/class/backlight/intel_backlight"

    property string kind: ""
    property real level: 0
    property bool muted: false
    property bool ready: false

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property real volume: root.sink?.audio?.volume ?? 0
    readonly property bool sinkMuted: root.sink?.audio?.muted ?? false

    property real ceiling: 0
    property real raw: 0

    readonly property real brightness:
        root.ceiling > 0 ? root.raw / root.ceiling : 0

    readonly property bool visible: root.kind !== ""

    // A fresh shell reads both devices immediately, and neither
    // reading is something the user just did.
    function announce(which: string, value: real, silent: bool): void {
        if (!root.ready) return;
        root.kind = which;
        root.level = value;
        dwell.restart();
        if (!silent) cue.running = true;
    }

    onVolumeChanged: root.announce("volume", root.volume, false)
    onSinkMutedChanged: {
        root.muted = root.sinkMuted;
        root.announce("volume", root.volume, root.sinkMuted);
    }
    // Brightness changes are visible by definition, so a
    // sound for them is noise.
    onBrightnessChanged: root.announce("brightness",
        root.brightness, true)

    Timer {
        running: true
        interval: root.settleMs

        onTriggered: root.ready = true
    }

    Timer {
        id: dwell

        interval: root.dwellMs

        onTriggered: root.kind = ""
    }

    Process {
        id: cue

        command: [Quickshell.env("HOME")
            + "/.config/hypr/scripts/notify-sound", "volume"]
    }

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    FileView {
        path: root.backlight + "/max_brightness"
        blockLoading: true

        onLoaded: root.ceiling = parseInt(this.text(), 10) || 0
    }

    FileView {
        path: root.backlight + "/brightness"
        watchChanges: true
        blockLoading: true

        onFileChanged: this.reload()
        onLoaded: root.raw = parseInt(this.text(), 10) || 0
    }
}
