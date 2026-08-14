pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower

Singleton {
    id: root

    readonly property string daemonName: "net.hadess.PowerProfiles"

    property bool available: false

    readonly property var choices: [
        {
            profile: PowerProfile.PowerSaver,
            label: "Saver",
            glyph: "󰾆"
        },
        {
            profile: PowerProfile.Balanced,
            label: "Balanced",
            glyph: "󰾅"
        },
        {
            profile: PowerProfile.Performance,
            label: "Performance",
            glyph: "󰓅"
        }
    ]

    readonly property var options: root.choices.filter(
        choice => choice.profile !== PowerProfile.Performance
            || PowerProfiles.hasPerformanceProfile)

    readonly property int current: PowerProfiles.profile

    function select(profile: int): void {
        PowerProfiles.profile = profile;
    }

    Process {
        running: true
        command: ["busctl", "--system", "status", root.daemonName]

        onExited: (code, status) => root.available = code === 0
    }
}
