import QtQuick
import Quickshell.Io
import qs.services

Rectangle {
    id: root

    required property string slug

    readonly property string path:
        `${Theme.themeDir}/${root.slug}.json`

    readonly property int inset: scheme.spacing.normal ?? 0

    visible: root.slug !== ""
    color: scheme.bg
    radius: scheme.radii.large ?? 0
    border.width: scheme.sizes.borderWidth ?? 0
    border.color: scheme.border
    clip: true

    function parsed(payload: string): var {
        try {
            return JSON.parse(payload);
        } catch (error) {
            console.error(
                `donbox: ${root.path} is not valid JSON:`, error);
            return ({});
        }
    }

    ThemePreviewScheme {
        id: scheme
    }

    FileView {
        path: root.path
        blockLoading: true
        printErrors: false

        onLoaded: scheme.data = root.parsed(this.text())
        onLoadFailed: scheme.data = ({})
    }

    ThemePreviewBar {
        id: bar

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: root.inset
        scheme: scheme
    }

    ThemePreviewSwatches {
        id: swatches

        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: root.inset
        scheme: scheme
    }

    ThemePreviewWindow {
        anchors.top: bar.bottom
        anchors.bottom: swatches.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: root.inset
        scheme: scheme
        caption: root.slug
    }
}
