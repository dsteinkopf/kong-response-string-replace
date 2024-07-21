local function check_for_body_replace_pattern(value)
    for _, body_replace_pattern in ipairs(value) do
        local found = string.find(body_replace_pattern, "###")
        if not found then
            return false, "body_replace_pattern '" .. body_replace_pattern .. "' has no ### seperator."
        end
    end
    return true
end

local function check_for_header_replace_pattern(value)
    for _, header_replace_pattern in ipairs(value) do
        local found = header_replace_pattern:match("^(.+):(.+)###(.*)$")
        if not found then
            return false, "header_replace_pattern '" .. header_replace_pattern .. "' must have a ':' and a '###' seperator."
        end
    end
    return true
end

-- see https://docs.konghq.com/gateway/3.4.x/plugin-development/configuration/
-- see https://github.com/Kong/kong-plugin/blob/master/kong/plugins/myplugin/schema.lua

local typedefs = require "kong.db.schema.typedefs"


return {
  name = "kong-response-string-replace",
  fields = {
    {
      -- this plugin will only be applied to Services or Routes
      consumer = typedefs.no_consumer
    },
    {
      -- this plugin will only run within Nginx HTTP module
      protocols = typedefs.protocols_http
    },
    {
      config = {
        type = "record",
        fields = {
          { content_types = {type = "array", default = {}, elements = { type = "string" }, }, },
          { uri_patterns = {type = "array", default = {}, elements = { type = "string" }, }, },
          { body_replace_patterns = {type = "array", default = {}, elements = { type = "string" }, custom_validator = check_for_body_replace_pattern }, },
          { header_replace_patterns = {type = "array", default = {}, elements = { type = "string" }, custom_validator = check_for_header_replace_pattern } },
        },
      },
    },
  },
}
