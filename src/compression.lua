local zlib = require "zlib"
-- see https://stackoverflow.com/questions/45216069/lua-how-to-gzip-a-string-gzip-not-zlib-in-memory
-- and https://github.com/brimworks/lua-zlib


local _M = {}

-- input:  string
-- output: string compressed with gzip
function _M.compress(uncompressed)
    local level = 9
    local windowSize = 15+16
    local stream = zlib.deflate(level, windowSize)
    return stream(uncompressed, "finish")
end

-- input:  string compressed with gzip
-- output: string
function _M.decompress(compressed)
    local stream = zlib.inflate()
    return stream(compressed)
end

return _M