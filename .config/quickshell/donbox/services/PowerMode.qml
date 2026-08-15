pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower

Singleton {
    id: root

    readonly property string daemonName: "net.hadess.PowerProfiles"

    readonly property int writeDelayMs: 300
    readonly property int settleMs: 5000
    readonly property int jsonIndent: 4

    readonly property string mainsSource: "ac"
    readonly property string batterySource: "battery"

    property bool available: false

    readonly property var choices: [
        {
            profile: PowerProfile.PowerSaver,
            name: "power-saver",
            label: "Saver",
            glyph: "󰾆"
        },
        {
            profile: PowerProfile.Balanced,
            name: "balanced",
            label: "Balanced",
            glyph: "󰾅"
        },
        {
            profile: PowerProfile.Performance,
            name: "performance",
            label: "Performance",
            glyph: "󰓅"
        }
    ]

    readonly property var options: root.choices.filter(
        choice => choice.profile !== PowerProfile.Performance
            || PowerProfiles.hasPerformanceProfile)

    readonly property int current: PowerProfiles.profile

    readonly property var sourceLabels: [
        { source: root.mainsSource, label: qsTr("mains") },
        { source: root.batterySource, label: qsTr("battery") }
    ]

    readonly property string source: UPower.onBattery
        ? root.batterySource
        : root.mainsSource

    readonly property string stateHome:
        Quickshell.env("XDG_STATE_HOME")
        ?? `${Quickshell.env("HOME")}/.local/state`

    readonly property string stateDirectory: `${root.stateHome}/donbox`

    readonly property string statePath:
        `${root.stateDirectory}/power-profiles.json`

    property string appliedSource: ""
    property var remembered: ({})
    property bool loaded: false
    property bool settled: false

    readonly property var rememberedRows: root.sourceLabels
        .map(entry => ({
            label: entry.label,
            choice: root.choiceNamed(root.remembered[entry.source])
        }))
        .filter(row => row.choice !== undefined)

    function choiceNamed(name: var): var {
        return root.choices.find(choice => choice.name === name);
    }

    function choiceFor(profile: int): var {
        return root.choices.find(choice => choice.profile === profile);
    }

    function remember(source: string, profile: int): void {
        const choice = root.choiceFor(profile);
        if (!choice) return;
        const next = Object.assign({}, root.remembered);
        next[source] = choice.name;
        root.remembered = next;
    }

    function select(profile: int): void {
        PowerProfiles.profile = profile;
        root.remember(root.source, profile);
    }

    function restore(): void {
        const choice = root.choiceNamed(root.remembered[root.source]);
        if (!choice) return;
        PowerProfiles.profile = choice.profile;
    }

    function followSource(): void {
        if (root.appliedSource === root.source) return;
        const known = root.appliedSource !== "";
        root.appliedSource = root.source;
        if (known && root.settled) root.restore();
    }

    function reparse(): void {
        try {
            root.remembered = JSON.parse(file.text()) ?? ({});
        } catch (error) {
            root.remembered = ({});
        }
    }

    onSourceChanged: root.followSource()

    onRememberedChanged: {
        if (!root.loaded) return;
        writeBack.restart();
    }

    Component.onCompleted: {
        Quickshell.execDetached(["mkdir", "-p", root.stateDirectory]);
        root.reparse();
        root.loaded = true;
        root.followSource();
    }

    Timer {
        id: writeBack

        interval: root.writeDelayMs

        onTriggered: file.setText(
            JSON.stringify(root.remembered, null, root.jsonIndent))
    }

    Timer {
        id: settle

        running: true
        interval: root.settleMs

        onTriggered: {
            root.followSource();
            root.settled = true;
        }
    }

    Process {
        running: true
        command: ["busctl", "--system", "status", root.daemonName]

        onExited: (code, status) => root.available = code === 0
    }

    FileView {
        id: file

        path: root.statePath
        blockLoading: true
        atomicWrites: true
        printErrors: false
    }
}
