import QtQuick
import QtTest
import "../../.config/quickshell/donbox/services/logic"

TestCase {
    name: "LuaLiteral"

    LuaLiteral {
        id: lua
    }

    function test_a_string_comes_back_quoted() {
        compare(lua.quoted("ember"), '"ember"');
    }

    function test_a_quote_inside_is_escaped() {
        compare(lua.quoted('say "hi"'), '"say \\"hi\\""');
    }

    function test_a_backslash_is_escaped_before_the_quotes() {
        compare(lua.quoted("C:\\path"), '"C:\\\\path"');
    }

    function test_a_number_is_written_bare() {
        compare(lua.literal(4), "4");
    }

    function test_a_boolean_is_written_bare() {
        compare(lua.literal(true), "true");
    }

    function test_nothing_is_written_as_lua_spells_it() {
        compare(lua.literal(null), "nil");
    }

    function test_a_list_keeps_its_order() {
        compare(lua.list([1, 2, 3]), "{ 1, 2, 3 }");
    }

    function test_a_table_names_its_fields() {
        compare(lua.table({ zoom_step: 1.5 }), "{ zoom_step = 1.5 }");
    }

    function test_a_field_left_undefined_is_left_out() {
        compare(lua.table({ kept: 1, gone: undefined }),
            "{ kept = 1 }");
    }

    function test_a_table_nests() {
        compare(lua.table({ devices: { touchpad: { tap: true } } }),
            "{ devices = { touchpad = { tap = true } } }");
    }
}
