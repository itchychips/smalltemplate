local variables = {}
variables.my_value = "'my value is here, but notice the lack of capital V for the variable name'"

local output = [[
Here is my value, but it will no longer error, because I am using a lowercase V:

${my_value}
]]

return output,variables
