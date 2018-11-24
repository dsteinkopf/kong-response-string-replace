local _M = {}

function _M.is_content_type(actual_full_content_type, content_types)
    if content_types == nil or actual_full_content_type == nil then
        return false
    end
    -- split off charset
    local actual_base_content_type, _ = string.match(actual_full_content_type,  "^%s*(%S+)%s*;(.*)$")
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
    if replace_patterns == nil then
        return body
    end
    for _, pattern, replace in iter(replace_patterns) do
        -- kong.log("pattern=", pattern, ", replace=", replace)
        body = body:gsub(pattern, replace)
    end
    return body
end

function _M.matches_one_of(uri, uri_patterns)
    if uri_patterns == nil then
        return false
    end
    for _, uri_pattern in ipairs(uri_patterns) do
        if string.find(uri, uri_pattern) then
            return true
        end
    end

    return false
end

function _M.tansform_headers(headers, header_replace_patterns)
    if header_replace_patterns == nil or headers == nil then
        return headers
    end
    for _, header_replace_pattern in ipairs(header_replace_patterns) do
        local header_name, pattern, replace = header_replace_pattern:match("^([^:]+):(.+)###(.*)$")
        if headers[header_name] then
            if type(headers[header_name]) == "string" then
                headers[header_name] = string.gsub(headers[header_name], pattern, replace)
            else
                local header_arr = headers[header_name]
                for index, value in ipairs(header_arr) do
                    header_arr[index] = string.gsub(value, pattern, replace)
                end
            end
        end
    end
end

return _M