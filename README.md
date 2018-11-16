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

* `content_types`: List of content type the replacements should be done on. 
  No charset. E.g. `text/html`.
  Should not be empty as no replacements would be done at all then.
* `replace_patterns`: List of pattern/replacement pairs, seperated by `###`. 
  Patterns are Lua patterns.
  E.g. `my ugly text###my nice text`, `https%:%/%/internal%-server%.local%:8888###https://external-server.my.tld`

Raise an issue if there's anything more you'd like to see.

## Misc

Thanks to the creator of https://github.com/HappyValleyIO/kong-http-to-https-redirect.
