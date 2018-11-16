package = "kong-response-string-replace"
version = "0.14.1-0"
source = {
    url = "git://github.com/dsteinkopf/kong-response-string-replace",
    branch = "master"
}
description = {
    summary = "A Kong plugin for string replacements in the response stream.",
    detailed = [[
      Find and replace patterns in the response stream.
    ]],
    homepage = "https://github.com/dsteinkopf/kong-response-string-replace",
    license = "MIT"
}
dependencies = {
}
build = {
    type = "builtin",
    modules = {
    ["kong.plugins.kong-response-string-replace.handler"] = "src/handler.lua",
    ["kong.plugins.kong-response-string-replace.schema"] = "src/schema.lua",
    }
}
