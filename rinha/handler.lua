--
-- Implementar cusotm logic
-- https://docs.konghq.com/gateway/latest/plugin-development/custom-logic/
--
-- criptografia AES:
-- https://github.com/c64bob/lua-resty-aes
--
-- UUID:
-- https://thibaultcha.github.io/lua-resty-jit-uuid
--
-- para gerar key
-- openssl enc -aes-256-cbc -k secret -P -md sha1
--
-- testar com:
--curl -X POST -H "Content-Type: application/json" -d '{"nome1":"valor1","cpf":"valor2"}' localhost:8000/post
--
local aes = require "resty.aes"
local str = require "resty.string"
local cjson = require "cjson.safe"
local uuid = require 'resty.jit-uuid'

local access = require "kong.plugins.rinha.access"
local kong_meta = require "kong.meta"

local function encrypt_and_encode(data, key)
    local salt = uuid()
    local eight_chars_salt = salt:sub(1, 8) -- salt insere aleatoriedade
    local aes_256_cbc_md5 = aes:new(key, eight_chars_salt, aes.cipher(256, "cbc"), aes.hash.sha512, 5)
    if not aes_256_cbc_md5 then
        return nil, "encrypt_and_encode: failed to create the AES object"
    end

    local encrypted = aes_256_cbc_md5:encrypt(data)
    if not encrypted then
        return nil, "encrypt_and_encode: failed to encrypt data"
    end

    return ngx.encode_base64(encrypted)
end

-- Hook que será chamado para transformar o body do request
local function transform_request_body(body)
    if not body then
        return nil, "transform_request_body: missing body"
    end
    local json_body = cjson.encode(body)
    if not json_body then
        return nil, "transform_request_body: failed to encode body into json"
    end
    kong.log.info("transform_request_body called: ".. json_body)

    local key = "Oij6xoB0jievau4aebav3paShahlul3z"

    -- Criptografar e codificar o CPF
    if body.cpf then
        local encrypted_cpf, err = encrypt_and_encode(body.cpf, key)
        if err then
            return nil, err
        end
        kong.log.info("transform_request_body encrypted_cpf = ".. encrypted_cpf)
        body.cpf = encrypted_cpf
    end
    -- Criptografar e codificar o email
    if body.email then
        local encrypted_email, err = encrypt_and_encode(body.email, key)
        if err then
            return nil, err
        end
        kong.log.info("transform_request_body encrypted_email = ".. encrypted_email)
        body.email = encrypted_email
    end
    return body
end

local RinhaPluginHandler = {
    VERSION = "0.1.0",
    PRIORITY = 1150,
}

function RinhaPluginHandler:access(conf)
    kong.log.info("RinhaPluginHandler access phase called...")
    local key = "Oij6xoB0jievau4aebav3paShahlul3z"
    local encrypted_body, err = transform_request_body(kong.request.get_body(), key)
    if err then
        kong.log.info(err)
    else
        local encoded_body = cjson.encode(encrypted_body)
        --ngx.req.set_body_data(encoded_body)
        ngx.req.set_body_data(encoded_body)
    end
    -- kong.log.info("RinhaPluginHandler access encrypted_text: " .. encrypted_text .. "...")
end

function RinhaPluginHandler:log(conf)
    kong.log.info("RinhaPluginHandler log phase called...")
end


return RinhaPluginHandler
