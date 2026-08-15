pragma Singleton

import QtQuick
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property int indent: 2
    readonly property string silent: ""
    readonly property string testApp: qsTr("Donbox settings")
    readonly property string testSummary: qsTr("Test notification")
    readonly property string testBody:
        qsTr("This is how %1 will sound and speak.")

    readonly property var urgencies: [
        { key: "low", word: qsTr("Low") },
        { key: "normal", word: qsTr("Normal") },
        { key: "critical", word: qsTr("Critical") }
    ]

    readonly property string soundsDirectory:
        `${Preferences.configHome}/hypr/scripts/sounds`

    readonly property var applications:
        Object.keys(NotificationRules.applications).sort()

    readonly property var seen: NotificationStore.entries
        .map(entry => entry.app)
        .filter(app => app !== ""
            && root.applications.indexOf(app) < 0)

    readonly property var unruled: root.seen
        .filter((app, index) => root.seen.indexOf(app) === index)
        .sort()

    property var sounds: []

    function ruleFor(app: string): var {
        return NotificationRules.applications[app] ?? ({});
    }

    function defaultsFor(urgency: string): var {
        return NotificationRules.defaults[urgency] ?? ({});
    }

    function branch(name: string): var {
        return Object.assign({}, NotificationRules.data[name] ?? ({}));
    }

    function save(name: string, updated: var): void {
        const next = Object.assign({}, NotificationRules.data);
        next[name] = updated;
        file.setText(JSON.stringify(next, null, root.indent));
    }

    function amended(entry: var, field: string, updated: var): var {
        const next = Object.assign({}, entry);
        next[field] = updated;
        return next;
    }

    function setDefault(urgency: string, field: string,
        updated: var): void {
        const defaults = root.branch("defaults");
        defaults[urgency] =
            root.amended(root.defaultsFor(urgency), field, updated);
        root.save("defaults", defaults);
    }

    function setRule(app: string, field: string, updated: var): void {
        const applications = root.branch("applications");
        applications[app] =
            root.amended(root.ruleFor(app), field, updated);
        root.save("applications", applications);
    }

    function forgetRule(app: string): void {
        const applications = root.branch("applications");
        delete applications[app];
        root.save("applications", applications);
    }

    function test(app: string, urgency: string): void {
        Quickshell.execDetached(["notify-send", "-a", app,
            "-u", urgency, root.testSummary,
            root.testBody.arg(app)]);
    }

    function gather(): void {
        const names = [];
        for (let index = 0; index < folder.count; index++) {
            names.push(folder.get(index, "fileBaseName"));
        }
        root.sounds = names;
    }

    FolderListModel {
        id: folder

        folder: `file://${root.soundsDirectory}`
        nameFilters: ["*.wav"]
        showDirs: false
        sortField: FolderListModel.Name

        onCountChanged: root.gather()
    }

    FileView {
        id: file

        path: NotificationRules.path
        atomicWrites: true
        printErrors: false
    }
}
