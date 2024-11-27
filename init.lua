function isValidHeader(header_secret_map)
    local headers = ngx.req.get_headers()
    for header, secret in pairs(header_secret_map) do
        local headerValue = headers[header]
        local secretValue = ngx.var[secret]

        if headerValue and secretValue and headerValue == secretValue then
            return true
        end
    end
    return false
end
