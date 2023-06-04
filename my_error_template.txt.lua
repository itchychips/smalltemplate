local variables = {}
variables.my_Value = "'my value is here, but notice the capital V for the variable name'"

local output = [[
Here is my value, but it will error, because I am not using a lowercase V:

${my_value}
]]

return output,variables
