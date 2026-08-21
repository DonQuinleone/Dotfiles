import QtQuick
import QtTest
import "../../.config/quickshell/donbox/services/logic"

TestCase {
    name: "VolumeCurve"

    VolumeCurve {
        id: curve
    }

    function test_a_level_is_read_as_a_percentage() {
        compare(curve.percent(0.5), "50%");
    }

    function test_a_percentage_is_rounded_to_a_whole_one() {
        compare(curve.percent(0.333), "33%");
    }

    function test_silence_reads_as_none_of_it() {
        compare(curve.percent(0), "0%");
    }

    function test_every_level_has_a_word_for_it() {
        for (let level = 0; level <= 1.0; level += 0.01) {
            verify(curve.wordFor(curve.volumeWords, level).length > 0);
        }
    }

    function test_the_words_go_from_silent_to_loud() {
        compare(curve.wordFor(curve.volumeWords, 0), "SILENT");
        compare(curve.wordFor(curve.volumeWords, 0.1), "FAINT");
        compare(curve.wordFor(curve.volumeWords, 0.3), "QUIET");
        compare(curve.wordFor(curve.volumeWords, 0.6), "MODERATE");
        compare(curve.wordFor(curve.volumeWords, 1.0), "LOUD");
    }

    function test_a_readout_carries_both() {
        compare(curve.readout(curve.volumeWords, 0.9), "90% · LOUD");
    }
}
