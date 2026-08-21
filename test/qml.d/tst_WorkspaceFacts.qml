import QtQuick
import QtTest
import "../../.config/quickshell/donbox/services/logic"

TestCase {
    name: "WorkspaceFacts"

    WorkspaceFacts {
        id: facts
    }

    function test_a_workspace_reports_how_its_tiles_are_arranged() {
        compare(facts.layoutOf({ lastIpcObject: {
            tiledLayout: "dwindle" } }), "dwindle");
    }

    function test_a_workspace_that_has_not_answered_yet() {
        compare(facts.layoutOf(null), "");
        compare(facts.layoutOf({}), "");
    }

    function test_a_floating_window_in_front_is_what_counts() {
        verify(facts.floatingOn({ floating: true,
            workspace: { name: "2" } }, "2"));
    }

    function test_a_tiled_window_leaves_the_layout_standing() {
        verify(!facts.floatingOn({ floating: false,
            workspace: { name: "2" } }, "2"));
    }

    function test_a_floating_window_elsewhere_is_not_ours() {
        verify(!facts.floatingOn({ floating: true,
            workspace: { name: "3" } }, "2"));
    }

    function test_nothing_focused_means_nothing_floating() {
        verify(!facts.floatingOn(null, "2"));
    }
}
