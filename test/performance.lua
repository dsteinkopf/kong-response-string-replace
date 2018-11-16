local replacements = require "src.replacements"

-- local is_content_type = replacements.is_content_type
local transform_body = replacements.transform_body

-- data
local filename = "test/testresponse.html"
local replacement_patterns = {
    "https%:%/%/my%-internal%.server%:9999###https://nerdblog.steinkopf.net",
    "https%:%/%/my%-internal%.server%:9999###https://nerdblog.steinkopf.net",
    "https%:%/%/my%-internal%.server%:9999###https://nerdblog.steinkopf.net",
    "https%:%/%/my%-internal%.server%:9999###https://nerdblog.steinkopf.net",
    "https%:%/%/my%-internal%.server%:9999###https://nerdblog.steinkopf.net",
    "https%:%/%/my%-internal%.server%:9999###https://nerdblog.steinkopf.net",
    "https%:%/%/my%-internal%.server%:9999###https://nerdblog.steinkopf.net",
    "http%:%/%/my%-internal%.server%:9999###https://nerdblog.steinkopf.net"
}

-- load test data
local file = assert(io.open(filename, "r"))
local filebody = file:read("*all")
local body = ""
for i = 1,11 do
    body = body .. filebody
end
file:close()

-- run and measure test
local start_time = os.clock()
local run_count = 100
for i = 1,run_count do
    local transformed_body = transform_body(replacement_patterns, body)
    assert(transformed_body:find("nerdblog.steinkopf.net"))
end
local seconds_taken = os.clock() - start_time
print ("seconds_taken per run: " .. seconds_taken * 1000 / run_count .. " ms")