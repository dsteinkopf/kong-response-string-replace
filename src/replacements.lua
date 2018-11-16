local _M = {}

function _M.is_content_type(actual_full_content_type, content_types)
    -- split off charset
    local actual_base_content_type, _ = string.match(actual_full_content_type,  "^(.+)%s*;(.*)$")
    actual_base_content_type = actual_base_content_type or actual_full_content_type
    for _, content_type in ipairs(content_types) do
        if actual_base_content_type == content_type then
            return true
        end
    end
    return false
end

local function iter(replace_patterns)
    return function(replace_patterns, i, _, _)
        i = i + 1
        local current_pair = replace_patterns[i]
        if current_pair == nil then -- n + 1
            return nil
        end

        local current_pattern, current_replace = string.match(current_pair, "^(.+)###(.*)$")

        return i, current_pattern, current_replace
    end, replace_patterns, 0
end

function _M.transform_body(replace_patterns, body)
    for _, pattern, replace in iter(replace_patterns) do
        -- kong.log("pattern=", pattern, ", replace=", replace)
        body = body:gsub(pattern, replace)
    end
    return body
end

return _M