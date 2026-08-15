import QtQuick
import qs.services

Row {
    id: root

    readonly property string sigil: ">"
    readonly property string bullet: "•"

    readonly property int bullets: Math.min(
        Lock.entry.length, LockMetrics.maximumBullets)

    width: parent.width
    spacing: Theme.spacing.tight ?? 0

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: `${Lock.instruction} ${root.sigil}`
        color: Theme.palette.accent ?? "white"
        font.family: Theme.fonts.mono ?? ""
        font.pixelSize: LockMetrics.entrySize
        font.weight: Theme.fontWeights.bold ?? 0
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: Lock.masked
            ? root.bullet.repeat(root.bullets)
            : Lock.entry
        color: Theme.palette.fg ?? "white"
        font.family: Theme.fonts.mono ?? ""
        font.pixelSize: LockMetrics.entrySize
    }

    CrtCursor {
        anchors.verticalCenter: parent.verticalCenter
        width: LockMetrics.caretWidth
        height: LockMetrics.entryLine
    }
}
