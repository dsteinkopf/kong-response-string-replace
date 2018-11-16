# kong-response-string-replace

A Kong plugin for string replacements in the response stream.
This could be useful e.g. to replace internal by external URLs.

## Installation

Run:
```
luarocks install *.rockspec
```

Then in the kong.yml add 

```
custom_plugins:
  - kong-response-string-replace
```

Run kong reload or start and add the plugin as normal.

### Docker installation

Derive your kong images `FROM kong` and add something like
```
FROM kong

RUN apk update && apk add git
RUN git clone https://github.com/dsteinkopf/kong-response-string-replace
RUN cd kong-response-string-replace && luarocks install *.rockspec
```

Then put `KONG_CUSTOM_PLUGINS: kong-response-string-replace` into your environment when starting the kong container.

## Info

This plugin's priority is set to 1250.
So it is handled after ip-restriction, bot-detection, cors and after [kong-http-to-https-redirect](https://github.com/dsteinkopf/kong-http-to-https-redirect/) - but before jwt and other authentication plugins
(see last paragraph in [Kongo Plugin Documentation - Custom Logic](https://docs.konghq.com/0.14.x/plugin-development/custom-logic/)).



## Configuration

* `content_types`: 
    * _type_: list of strings
    * _default value_: empty
    * _example_: `text/html`
    * List of content types the replacements should be done on. 
        Exact match (not pattern patch) is done without charset part of content type.
        
* `uri_patterns`: 
    * _type_: list of strings
    * _default value_: empty
    * _example_: `%.html$`
    * List of patterns that match URIs of requests where the replacements shall be done.
     
* `body_replace_patterns`:
    * _type_: list of strings formed `PATTERN###REPLACEMENT`
    * _default value_: empty (= no body replacements to be done)
    * _example_: `my ugly text###my nice text`, `https%:%/%/internal%-server%.local%:8888###https://external-server.my.tld`
    * List of pattern/replacement pairs. 
        Patterns are Lua patterns. 
        So they are case sensitive. 
        Spaces are _not_ ignored. 
        Remember to quote special characters like `.`.
* `header_replace_patterns`:
    * _type_: list of strings formed `HEADERNAME:PATTERN###REPLACEMENT`
    * _default value_: empty (= no header replacements to be done)
    * _example_: `Set-Cookie:internal%-server%.local###external-server.my.tld`, `Server:Apache.*$###HiddenServerName`
    * List of header name/pattern/replacement groups. 
        Patterns are Lua patterns. 
        So they are case sensitive.
        Spaces are _not_ ignored. 
        Remember to quote special characters like `.`.
        Header names must match exactly - case sensitive.

Note: Replacements (on headers and body) are done on all requests
that match either the content_types _or_ the replace_uri_patterns.
So they should not be both empty. 

## Misc

Thanks to the creator of https://github.com/HappyValleyIO/kong-http-to-https-redirect.
