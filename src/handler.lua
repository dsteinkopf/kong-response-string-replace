local BasePlugin = require "kong.plugins.base_plugin"
local replacements = require "kong.plugins.kong-response-string-replace.replacements"

local is_content_type = replacements.is_content_type
local transform_body = replacements.transform_body

local HttpFilterHandler = BasePlugin:extend()


-- handle redirect after ip-restriction, bot-detection, cors - but before jwt and other authentication plugins
-- see https://docs.konghq.com/0.14.x/plugin-development/custom-logic/
HttpFilterHandler.PRIORITY = 1250


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
