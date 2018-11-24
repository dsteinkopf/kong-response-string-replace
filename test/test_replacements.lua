local replacements = require "src.replacements"
local helper = require "test.helper"

-- luarocks install luaunit
luaunit = require('luaunit')


TestReplacements = {} -- class

function TestReplacements:test_tansform_headers()

    local headers = {
        h1="v1",
        h2={
            "v21bla",
            "v22bla"
        },
        h3="v3", -- headers are mode case insensitive by the system
        location="http://internal-server.abc:1234/dir/"
    }

    local transformed_headers_expected = {
        h1="v1",
        h2={
            "v2new1bla",
            "v2new2bla"
        },
        h3="v3new",
        location="https://external-server.tld/"
    }

    local header_replace_patterns = {
        "h2:v2###v2new",
        "h3:v3###v3new",
        "location:http://internal%-server%.abc:1234/dir/###https://external-server.tld/"
    }

    replacements.tansform_headers(headers, header_replace_patterns)
    luaunit.assertTrue(helper.deepcompare(headers, transformed_headers_expected, true))

    luaunit.assertEquals(replacements.tansform_headers(nil, nil), nil)
    luaunit.assertEquals(replacements.tansform_headers(headers, nil), headers)
end

function TestReplacements:test_matches_one_of()

    local uri_patterns_empty = {}
    local uri_patterns_one = { "bc" }
    local uri_patterns_many = { "abc", "%.html$" }

    local uri1 = "blabla"
    local uri2 = "test.html"
    local uri3 = "abc"

    luaunit.assertFalse(replacements.matches_one_of(uri1, uri_patterns_empty))
    luaunit.assertFalse(replacements.matches_one_of(uri1, uri_patterns_one))
    luaunit.assertFalse(replacements.matches_one_of(uri1, uri_patterns_many))

    luaunit.assertFalse(replacements.matches_one_of(uri2, uri_patterns_empty))
    luaunit.assertFalse(replacements.matches_one_of(uri2, uri_patterns_one))
    luaunit.assertTrue(replacements.matches_one_of(uri2, uri_patterns_many))

    luaunit.assertFalse(replacements.matches_one_of(uri3, uri_patterns_empty))
    luaunit.assertTrue(replacements.matches_one_of(uri3, uri_patterns_one))
    luaunit.assertTrue(replacements.matches_one_of(uri3, uri_patterns_many))

    luaunit.assertFalse(replacements.matches_one_of(uri1, nil))

end

function TestReplacements:test_transform_body()

    local replace_patterns_empty = {}
    local replace_patterns = { "abc###123", "xyz###DEF" }

    local body = "xabcdefghijklmnopqrstuvwxyzx-x123defghijklmnopqrstuvwDEFx"
    local body_transformed_expected = "x123defghijklmnopqrstuvwDEFx-x123defghijklmnopqrstuvwDEFx"

    luaunit.assertEquals(body, replacements.transform_body(replace_patterns_empty, body))
    luaunit.assertEquals(body_transformed_expected, replacements.transform_body(replace_patterns, body))
    luaunit.assertEquals(body, replacements.transform_body(nil, body))
end

function TestReplacements.test_is_content_type()

    local content_types_empty = {}
    local content_types = { "abc", "def" }

    luaunit.assertFalse(replacements.is_content_type("testvalue", content_types_empty))
    luaunit.assertFalse(replacements.is_content_type("testvalue", content_types))

    luaunit.assertTrue(replacements.is_content_type("abc", content_types))
    luaunit.assertFalse(replacements.is_content_type("abcdef", content_types))
    luaunit.assertTrue(replacements.is_content_type("abc; xyz", content_types))
    luaunit.assertTrue(replacements.is_content_type("abc ; xyz", content_types))
    luaunit.assertTrue(replacements.is_content_type(" abc ; xyz", content_types))
    luaunit.assertTrue(replacements.is_content_type("def;xyz", content_types))

    luaunit.assertFalse(replacements.is_content_type(nil, nil))
    luaunit.assertFalse(replacements.is_content_type(nil, content_types))
    luaunit.assertFalse(replacements.is_content_type("aaa", nil))
end

os.exit( luaunit.LuaUnit.run() )
