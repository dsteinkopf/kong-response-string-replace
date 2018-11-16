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

return {
  no_consumer = true,
  fields = {
      content_types = {type = "array", default = {}},
      uri_patterns = {type = "array", default = {}},
      body_replace_patterns = {type = "array", default = {}, func = check_for_body_replace_pattern },
      header_replace_patterns = {type = "array", default = {}, func = check_for_header_replace_pattern }
  }
}
