pragma Singleton

import QtQuick
import Quickshell

// The lit fraction, from Meeus chapter 48. Counting whole
// months off a remembered new moon drifts half a day,
// which at the crescents is a third of the moon.
Singleton {
    id: root

    readonly property real fullPhase: 0.5
    readonly property real wholeTurn: 1
    readonly property real degreesPerTurn: 360
    readonly property real halfTurnDegrees: 180

    readonly property real julianEpoch: 2440587.5
    readonly property real julianMillennium: 2451545
    readonly property real daysPerCentury: 36525
    readonly property real msPerDay: 86400000

    readonly property var faces: [
        { until: 0.02, label: "New moon" },
        { until: 0.24, label: "Waxing crescent" },
        { until: 0.26, label: "First quarter" },
        { until: 0.49, label: "Waxing gibbous" },
        { until: 0.51, label: "Full moon" },
        { until: 0.74, label: "Waning gibbous" },
        { until: 0.76, label: "Last quarter" },
        { until: 0.98, label: "Waning crescent" },
        { until: 1.01, label: "New moon" }
    ]

    property date now: new Date()

    readonly property real centuries: {
        const julian = root.now.getTime() / root.msPerDay
            + root.julianEpoch;
        return (julian - root.julianMillennium)
            / root.daysPerCentury;
    }

    readonly property real elongation: {
        const time = root.centuries;
        return 297.8501921 + 445267.1114034 * time
            - 0.0018819 * Math.pow(time, 2)
            + Math.pow(time, 3) / 545868
            - Math.pow(time, 4) / 113065000;
    }

    readonly property real sunAnomaly: {
        const time = root.centuries;
        return 357.5291092 + 35999.0502909 * time
            - 0.0001536 * Math.pow(time, 2)
            + Math.pow(time, 3) / 24490000;
    }

    readonly property real moonAnomaly: {
        const time = root.centuries;
        return 134.9633964 + 477198.8675055 * time
            + 0.0087414 * Math.pow(time, 2)
            + Math.pow(time, 3) / 69699
            - Math.pow(time, 4) / 14712000;
    }

    readonly property real phaseAngle: {
        const spread = root.elongation;
        const sun = root.sunAnomaly;
        const moon = root.moonAnomaly;
        return root.halfTurnDegrees - spread
            - 6.289 * root.sine(moon)
            + 2.100 * root.sine(sun)
            - 1.274 * root.sine(2 * spread - moon)
            - 0.658 * root.sine(2 * spread)
            - 0.214 * root.sine(2 * moon)
            - 0.110 * root.sine(spread);
    }

    readonly property real illuminated:
        (1 + Math.cos(root.phaseAngle * Math.PI
            / root.halfTurnDegrees)) / 2

    readonly property bool waxing:
        root.turn(root.elongation) < root.halfTurnDegrees

    readonly property real phase: {
        const lit = Math.max(0, Math.min(1, root.illuminated));
        const part = Math.acos(1 - 2 * lit) / (2 * Math.PI);
        return root.waxing ? part : root.wholeTurn - part;
    }

    readonly property string label: root.nameFor(root.phase)

    function sine(degrees: real): real {
        return Math.sin(degrees * Math.PI / root.halfTurnDegrees);
    }

    function turn(degrees: real): real {
        const part = degrees % root.degreesPerTurn;
        return part < 0 ? part + root.degreesPerTurn : part;
    }

    function nameFor(part: real): string {
        return root.faces.find(face => part < face.until).label;
    }

    SystemClock {
        precision: SystemClock.Hours

        onDateChanged: root.now = this.date
    }
}
