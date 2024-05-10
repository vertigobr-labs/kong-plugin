local typedefs = require "kong.db.schema.typedefs"

return {
    name = "rinha", -- Must be unique
    fields = {
        { consumer = typedefs.no_consumer },
        { protocols = typedefs.protocols_http },
        { config = {
            type = "record",
            fields = {
                { rinha_url = { type = "string", required = true, default = "http://localhost:8000/rinha" } },
                { rinha_timeout = { type = "number", required = true, default = 10000 } },
            },
        }, },
    },
}
