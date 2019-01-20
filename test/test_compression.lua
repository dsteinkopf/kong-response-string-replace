local compression = require "src.compression"
local helper = require "test.helper"

luaunit = require('luaunit')


-- Mac:
-- brew install zlib
-- luarocks install lua-zlib ZLIB_DIR=/usr/local/Cellar/zlib/1.2.11/
-- lua test/test_compression.lua -v


TestCompression = {} -- class

function TestCompression:test_decompress()

    local testdata_gz = helper.readAll("test/testdata.gz")
    local uncompressed = compression.decompress(testdata_gz)
    luaunit.assertEquals("helloworld", uncompressed)
end


function TestCompression:test_compress()

    local orig = "test123"
    local compressed = compression.compress(orig)
    local uncompressed = compression.decompress(compressed)
    luaunit.assertEquals(orig, uncompressed)
end


os.exit( luaunit.LuaUnit.run() )
