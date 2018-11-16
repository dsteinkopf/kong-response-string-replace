local BasePlugin = require "kong.plugins.base_plugin"

local HttpFilterHandler = BasePlugin:extend()


-- handle redirect after ip-restriction, bot-detection, cors - but before jwt and other authentication plugins
-- see https://docs.konghq.com/0.14.x/plugin-development/custom-logic/
HttpFilterHandler.PRIORITY = 1250

local function is_content_type(actual_full_content_type, content_types)
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

local function transform_body(replace_patterns, body)
  for _, pattern, replace in iter(replace_patterns) do
    -- kong.log("pattern=", pattern, ", replace=", replace)
    body = body:gsub(pattern, replace)
  end
  return body
end

function HttpFilterHandler:new()
  HttpFilterHandler.super.new(self, "kong-response-string-replace")
end

-- Executed when all response headers bytes have been received from the upstream service
function HttpFilterHandler:header_filter(conf)
  HttpFilterHandler.super.header_filter(self)

  if is_content_type(ngx.header["content-type"], conf.content_types) then
    ngx.header["content-length"] = nil
    ngx.ctx.response_is_matched_content_type = true
  end
end

function HttpFilterHandler:body_filter(conf)
  HttpFilterHandler.super.body_filter(self)

  if ngx.ctx.response_is_matched_content_type then
    local chunk, eof = ngx.arg[1], ngx.arg[2]
    local ctx = ngx.ctx

    ctx.rt_body_chunks = ctx.rt_body_chunks or {}
    ctx.rt_body_chunk_number = ctx.rt_body_chunk_number or 1

    if eof then
      local transformed_body = transform_body(conf.replace_patterns, table.concat(ctx.rt_body_chunks))
      ngx.arg[1] = transformed_body
    else
      ctx.rt_body_chunks[ctx.rt_body_chunk_number] = chunk
      ctx.rt_body_chunk_number = ctx.rt_body_chunk_number + 1
      ngx.arg[1] = nil
    end
  end
end



return HttpFilterHandler
