pragma Singleton

import Quickshell
import "logic"

Singleton {
    readonly property alias step: curve.step
    readonly property alias volumeWords: curve.volumeWords

    function percent(level: real): string {
        return curve.percent(level);
    }

    function readout(scale: var, level: real): string {
        return curve.readout(scale, level);
    }

    VolumeCurve {
        id: curve
    }
}
