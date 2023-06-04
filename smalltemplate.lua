local module = {}

function module.template(input_path, allow_lua_evaluation, restricted_environment)
    local loaded,message = loadfile(input_path)
    if not loaded then
        error("error loading from " .. input_path .. ": " .. message)
    end
    restricted_environment = restricted_environment or {
        ["math"] = math,
        ["string"] = string,
        ["table"] = table,
    }
    setfenv(loaded, restricted_environment)
    local input,variables = loaded()

    local function replace(variable_name)
        if variable_name == "" then
            return "$"
        end

        local replacement = variables[variable_name]
        if replacement == nil then
            if allow_lua_evaluation then
                local loaded,message = loadstring(variable_name)
                if not loaded then
                    error("no substitution available for variable name '" .. variable_name .. "': " .. message)
                end
                local environment = variables
                environment["print"] = function(m)
                    io.stderr:write("(stderr-templ) " .. m .. "\n")
                end
                setfenv(loaded, environment)
                replacement = loaded() or ""
                return replacement
            end
            error("no substitution available for variable name '" .. variable_name .. "': (lua evaluation not enabled)")
        end
        return tostring(replacement)
    end

    local pattern = "${(.-)}"
    local output,count = input:gsub(pattern, replace)
    return output,count
end

return module
