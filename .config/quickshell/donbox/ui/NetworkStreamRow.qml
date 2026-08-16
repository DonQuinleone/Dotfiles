import QtQuick
import qs.services

Row {
    id: root

    readonly property int streamCount: 2

    // Defaulted rather than fixed: the live throughput and a
    // measured speed are the same two readings, so they are the
    // same row with different numbers in it.
    property var streams: [
        {
            glyph: "󰇚",
            caption: "Down",
            value: NetworkThroughput.downText
        },
        {
            glyph: "󰕒",
            caption: "Up",
            value: NetworkThroughput.upText
        }
    ]

    Repeater {
        model: root.streams

        NetworkStat {
            required property var modelData

            width: root.width / root.streamCount
            glyph: this.modelData.glyph
            caption: this.modelData.caption
            value: this.modelData.value
        }
    }
}
