local BasePlugin = require "kong.plugins.base_plugin"
local replacements = require "kong.plugins.kong-response-string-replace.replacements"
local compression = require "kong.plugins.kong-response-string-replace.compression"
local brotlienc = require "brotli.encoder"
local brotlidec = require "brotli.decoder"


local is_content_type = replacements.is_content_type
local transform_body = replacements.transform_body
local matches_one_of = replacements.matches_one_of
local tansform_headers = replacements.tansform_headers
local decompress = compression.decompress
local compress = compression.compress
local brotli_encoder = brotlienc:new()
local brotli_decoder = brotlidec:new()


local HttpFilterHandler = BasePlugin:extend()


-- handle redirect after ip-restriction, bot-detection, cors - but before jwt and other authentication plugins
-- see https://docs.konghq.com/0.14.x/plugin-development/custom-logic/
HttpFilterHandler.PRIORITY = 1250


function HttpFilterHandler:new()
  HttpFilterHandler.super.new(self, "kong-response-string-replace")
end

-- Executed for every request from a client and before it is being proxied to the upstream service
function HttpFilterHandler:access(conf)
  HttpFilterHandler.super.access(self)
end


  -- Executed when all response headers bytes have been received from the upstream service
function HttpFilterHandler:header_filter(conf)
  HttpFilterHandler.super.header_filter(self)

  local content_type_matches = is_content_type(ngx.header["content-type"], conf.content_types)
  local uri_matches = matches_one_of(ngx.var.uri, conf.uri_patterns)

  -- determine compression
  ngx.ctx.is_brotli = (ngx.header["content-encoding"] == "br")
  ngx.ctx.is_gzip = (not ngx.ctx.is_brotli and ngx.header["content-encoding"] == "gzip")

  if content_type_matches or uri_matches then
    ngx.header["content-length"] = nil
    tansform_headers(ngx.header, conf.header_replace_patterns)
    ngx.ctx.do_transformation = true
  end
end

-- Executed for each chunk of the response body received from the upstream service
function HttpFilterHandler:body_filter(conf)
  HttpFilterHandler.super.body_filter(self)

  if ngx.ctx.do_transformation then
    local chunk, eof = ngx.arg[1], ngx.arg[2]
    local ctx = ngx.ctx

    ctx.rt_body_chunks = ctx.rt_body_chunks or {}
    ctx.rt_body_chunk_number = ctx.rt_body_chunk_number or 1

    if eof then
      local body = table.concat(ctx.rt_body_chunks)
      if ngx.ctx.is_gzip then
        body = decompress(body)
      elseif ngx.ctx.is_brotli then
        body = brotli_decoder:decompress(body)
      end

      local transformed_body = transform_body(conf.body_replace_patterns, body)

      if ngx.ctx.is_gzip then
        transformed_body = compress(transformed_body)
      elseif ngx.ctx.is_brotli then
        transformed_body = brotli_encoder:compress(transformed_body)
      end

      ngx.arg[1] = transformed_body
    else
      ctx.rt_body_chunks[ctx.rt_body_chunk_number] = chunk
      ctx.rt_body_chunk_number = ctx.rt_body_chunk_number + 1
      ngx.arg[1] = nil
    end
  end
end



return HttpFilterHandler
