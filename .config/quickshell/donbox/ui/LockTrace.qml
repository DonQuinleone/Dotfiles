import QtQuick
import qs.services

Column {
    id: root

    // Every line carries its verdict as text as well as colour,
    // so nothing here depends on being able to tell them apart.
    readonly property var marks: ({
        "ok": "[ ok ]",
        "info": "[ .. ]",
        "warn": "[ ?? ]",
        "deny": "[ xx ]"
    })

    readonly property var tints: ({
        "ok": Theme.palette.good ?? "white",
        "info": Theme.palette.fgDim ?? "white",
        "warn": Theme.palette.warn ?? "white",
        "deny": Theme.palette.bad ?? "red"
    })

    width: parent.width
    spacing: Theme.spacing.hair ?? 0

    Repeater {
        model: Lock.trace

        Row {
            required property var modelData

            spacing: Theme.spacing.tight ?? 0

            Text {
                text: root.marks[parent.modelData.tag] ?? ""
                color: root.tints[parent.modelData.tag] ?? "white"
                font.family: Theme.fonts.mono ?? ""
                font.pixelSize: LockMetrics.traceSize
                font.weight: Theme.fontWeights.bold ?? 0
            }

            Text {
                width: root.width - x
                text: parent.modelData.text
                color: Theme.palette.fgDim ?? "white"
                elide: Text.ElideRight
                font.family: Theme.fonts.mono ?? ""
                font.pixelSize: LockMetrics.traceSize
            }
        }
    }
}
