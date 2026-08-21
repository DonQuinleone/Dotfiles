import QtQuick
import QtTest
import "../../.config/quickshell/donbox/services/logic"

TestCase {
    name: "Ranking"

    Ranking {
        id: ranking
    }

    function test_empty_needle_matches_everything() {
        compare(ranking.score("firefox", ""), 0);
    }

    function test_a_letter_that_is_absent_never_matches() {
        compare(ranking.score("firefox", "z"), ranking.noMatch);
    }

    function test_letters_must_come_in_order() {
        compare(ranking.score("firefox", "xif"), ranking.noMatch);
    }

    function test_case_is_not_asked_about() {
        compare(ranking.score("Firefox", "FIRE"),
            ranking.score("firefox", "fire"));
    }

    function test_the_start_of_the_name_beats_the_middle() {
        verify(ranking.score("firefox", "fire")
            > ranking.score("campfire", "fire"));
    }

    function test_the_start_of_a_word_beats_the_middle_of_one() {
        verify(ranking.score("open image viewer", "image")
            > ranking.score("reimagine", "image"));
    }

    function test_a_run_beats_the_same_letters_scattered() {
        verify(ranking.score("fire", "fir")
            > ranking.score("f-i-r", "fir"));
    }

    function test_a_wider_gap_costs_more() {
        verify(ranking.score("fxr", "fr") > ranking.score("fxxxr", "fr"));
    }
}
