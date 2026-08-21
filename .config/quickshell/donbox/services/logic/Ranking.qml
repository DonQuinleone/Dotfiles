import QtQuick

QtObject {
    id: root

    readonly property int noMatch: -1000000
    readonly property int startBonus: 12
    readonly property int runBonus: 8
    readonly property int wordBonus: 6
    readonly property int gapPenalty: 1
    readonly property var wordBreaks: [" ", "-", "_", ".", "/"]

    function score(haystack: string, needle: string): int {
        if (needle.length === 0) return 0;
        const target = haystack.toLowerCase();
        const pattern = needle.toLowerCase();
        let total = 0;
        let cursor = 0;
        let previous = -1;
        for (const letter of pattern) {
            const found = target.indexOf(letter, cursor);
            if (found < 0) return root.noMatch;
            total += root.placementBonus(target, found, previous);
            previous = found;
            cursor = found + 1;
        }
        return total;
    }

    function placementBonus(target: string, at: int,
        previous: int): int {

        if (at === 0) return root.startBonus;
        if (at === previous + 1) return root.runBonus;
        if (root.startsWord(target, at)) return root.wordBonus;
        return -root.gapPenalty * (at - previous);
    }

    function startsWord(target: string, at: int): bool {
        return root.wordBreaks.includes(target.charAt(at - 1));
    }
}
