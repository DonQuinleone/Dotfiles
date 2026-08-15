import QtQuick
import Qt.labs.folderlistmodel
import qs.services

FocusScope {
    id: root

    readonly property var pictures:
        ["*.png", "*.jpg", "*.jpeg", "*.webp"]

    readonly property int columns: Math.max(1,
        Math.floor(root.width / Metrics.settingsCellWidth))

    property int index: 0

    readonly property var keySteps: ({
        [Qt.Key_Left]: -1,
        [Qt.Key_Right]: 1
    })

    readonly property var keyRows: ({
        [Qt.Key_Up]: -1,
        [Qt.Key_Down]: 1
    })

    implicitHeight: Metrics.settingsGridHeight
    activeFocusOnTab: true

    function select(wanted: int): void {
        root.index = Math.max(0,
            Math.min(folder.count - 1, wanted));
    }

    function accept(): void {
        const chosen = folder.get(root.index, "filePath");
        if (!chosen) return;
        ThemeCatalogue.applyWallpaper(chosen);
    }

    function handle(event): void {
        const step = root.keySteps[event.key];
        if (step !== undefined) {
            root.select(root.index + step);
            event.accepted = true;
            return;
        }
        const row = root.keyRows[event.key];
        if (row === undefined) return;
        root.select(root.index + row * root.columns);
        event.accepted = true;
    }

    Keys.onPressed: event => root.handle(event)
    Keys.onReturnPressed: root.accept()
    Keys.onEnterPressed: root.accept()

    FolderListModel {
        id: folder

        folder: ThemeCatalogue.wallpapers
        nameFilters: root.pictures
        showDirs: false
        sortField: FolderListModel.Name
    }

    GridView {
        id: grid

        anchors.fill: parent
        clip: true
        cellWidth: Metrics.settingsCellWidth
        cellHeight: Metrics.settingsCellHeight
        model: folder
        currentIndex: root.index
        preferredHighlightBegin: 0
        preferredHighlightEnd: this.height
        highlightRangeMode: GridView.ApplyRange

        delegate: SettingsGridCell {
            required property url fileUrl
            required property string fileBaseName
            required property int index

            source: this.fileUrl
            label: this.fileBaseName
            selected: this.index === root.index
            focused: root.activeFocus && this.index === root.index
            current: `${Theme.wallpaper}` === `${this.fileUrl}`

            onActivated: {
                root.forceActiveFocus();
                root.select(this.index);
                root.accept();
            }
        }
    }
}
