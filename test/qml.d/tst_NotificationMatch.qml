import QtQuick
import QtTest
import "../../.config/quickshell/donbox/services/logic"

TestCase {
    id: root

    name: "NotificationMatch"

    readonly property var applications: ({
        "org.mozilla.firefox": { sound: "info" },
        "Slack": { sound: "message" }
    })

    readonly property var defaults: ({
        low: ({}),
        normal: { sound: "info" },
        critical: { sound: "critical" }
    })

    NotificationMatch {
        id: match
    }

    function test_nothing_reads_as_an_empty_string() {
        compare(match.plain(null), "");
        compare(match.plain(undefined), "");
    }

    function test_a_desktop_entry_is_taken_over_the_name() {
        compare(match.ruleFor(root.applications, "Slack",
            "org.mozilla.firefox").sound, "info");
    }

    function test_the_name_answers_when_there_is_no_entry() {
        compare(match.ruleFor(root.applications, "Slack", undefined)
            .sound, "message");
    }

    function test_an_application_names_itself_in_its_own_case() {
        compare(match.ruleFor(root.applications, "slack", undefined)
            .sound, "message");
    }

    function test_an_application_nobody_wrote_a_rule_for() {
        compare(Object.keys(match.ruleFor(root.applications,
            "Nothing", undefined)).length, 0);
    }

    function test_urgency_answers_when_the_application_does_not() {
        compare(match.fallbackFor(root.defaults, "critical").sound,
            "critical");
    }

    function test_an_urgency_with_nothing_set_against_it() {
        compare(Object.keys(
            match.fallbackFor(root.defaults, "low")).length, 0);
    }

    function test_the_rule_is_preferred_to_the_fallback() {
        compare(match.setting({ sound: "alarm" },
            { sound: "info" }, "sound"), "alarm");
    }

    function test_the_fallback_answers_for_what_the_rule_omits() {
        compare(match.setting({}, { sound: "info" }, "sound"),
            "info");
    }

    // A rule that names no sound is asking for silence, and must
    // not have the urgency's sound put back under it.
    function test_a_rule_can_silence_what_the_urgency_would_play() {
        compare(match.setting({ sound: "" },
            { sound: "info" }, "sound"), "");
    }
}
