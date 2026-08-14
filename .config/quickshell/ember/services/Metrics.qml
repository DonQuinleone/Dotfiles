pragma Singleton

import Quickshell

Singleton {
    id: root

    readonly property real generousScale: 1.4
    readonly property int surfaceWidthInMenus: 2
    readonly property int visibleRows: 7
    readonly property int gridColumns: 3
    readonly property int visibleGridRows: 2
    readonly property real thumbnailAspect: 1.6

    readonly property int gutter: Theme.spacing.normal ?? 0

    readonly property int rowHeight: Math.round(
        (Theme.sizes.hitTarget ?? 0) * root.generousScale)

    readonly property int rowIcon: Math.round(
        (Theme.sizes.iconNormal ?? 0) * root.generousScale)

    readonly property int surfaceWidth:
        (Theme.sizes.menuWidth ?? 0) * root.surfaceWidthInMenus

    readonly property int rowGap: Theme.spacing.hair ?? 0

    readonly property int listHeight:
        (root.rowHeight + root.rowGap) * root.visibleRows

    readonly property int scrollBarWidth: Theme.spacing.normal ?? 0

    readonly property int trackWidth:
        root.scrollBarWidth + root.gutter

    readonly property int thumbnailWidth: Theme.sizes.menuWidth ?? 0

    readonly property int thumbnailHeight: Math.round(
        root.thumbnailWidth / root.thumbnailAspect)

    readonly property int cellWidth:
        root.thumbnailWidth + root.gutter * 2

    readonly property int cellHeight:
        root.thumbnailHeight + root.rowHeight + root.gutter * 2

    readonly property int gridWidth: root.cellWidth * root.gridColumns

    readonly property int gridHeight:
        root.cellHeight * root.visibleGridRows
}
