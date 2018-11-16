local function check_for_value(value)
    for _, replace_pattern in ipairs(value) do
        local found = string.find(replace_pattern, "###")
        if not found then
            return false, "replace_pattern '" .. replace_pattern .. "' has no ### seperator"
        end
    end
    return true
end

return {
  no_consumer = true,
  fields = {
      content_types = {type = "array", default = {}},
      replace_patterns = {type = "array", default = {}, func = check_for_value}
  }
}
