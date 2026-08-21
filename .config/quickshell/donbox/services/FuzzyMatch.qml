pragma Singleton

import Quickshell
import "logic"

Singleton {
    readonly property alias noMatch: ranking.noMatch

    function score(haystack: string, needle: string): int {
        return ranking.score(haystack, needle);
    }

    Ranking {
        id: ranking
    }
}
