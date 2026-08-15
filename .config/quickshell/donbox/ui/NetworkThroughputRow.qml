import QtQuick
import qs.services

Row {
    id: root

    readonly property int streamCount: 2

    readonly property var streams: [
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
