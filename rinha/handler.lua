local access = require "kong.plugins.rinha.access"
local kong_meta = require "kong.meta"

local RinhaPluginHandler = {
    VERSION = kong_meta.version,
    PRIORITY = 1150,
}

function RinhaPluginHandler:access(conf)
    access.execute(conf)
end

function RinhaPluginHandler:log(conf)
    kong.log.info("RinhaPluginHandler access phase called")
end

return RinhaPluginHandler
