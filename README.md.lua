local variables = {}

variables.program_name = "smalltemplate"
variables.easter_egg = false

local output = [[
# ${program_name}

This is a Lua program and module that allows quick and easy templating.

This was written against luajit and tested against luajit and lua-5.1.

# License

Please see LICENSE.txt.  This is AGPL.

# How to use

Define your template in a lua script.  This script must return one or two
values.  In the case of one value, it is just the template text itself.  In the
case of two values, it should be the template text and a table of variables for
substitution.

Run the smalltemplate script on the template file.  You probably want to
redirect stdout to a file, like so:

    ./smalltemplate my_template.txt.lua > my_template.txt

On stderr, some diagnostics will be printed.

# Variables

Variables match the pattern:

    ${}{(.-)}

This matches all values like `${}{myvariable}`, `${}{my_variable}`,
`${}{my.variables}`, `${}{my variable with spaces}`, etc., but it does not match
greedily.

The variable lookup is done with `string.gsub` and a function to get the name
of the variable from the table.

# Other substitutions

It is possible to execute arbitrary lua code that only exposes the math,
string, table modules present in a standard luajit or lua-5.1 install.  To do
this, pass the parameter "true" to the smalltemplate script call, like so:

    ./smalltemplate my_template.txt.lua true > my_template.txt

Please note that this is not fully sandboxed, as an attacker could change those
modules and affect the outside content.  I do not recommend exposing such
functionality against a publicly-facing endpoint at this time.

# Escaping the `${}`

To print a literal ${} in the template, simply use this construct:

    ${}{}

Hacky, but it works, and doesn't complicate the very naive gsub matcher.

# Undefined variables

If at any point that an undefined variable is referenced, the script will
error.  Here is an example of such an error:

	${} ./smalltemplate my_error_template.txt.lua
	(stderr) Templating my_error_template.txt.lua.  Allowing lua evaluation in template: false
	lua: ./smalltemplate.lua:32: no substitution available for variable name 'my_value': (lua evaluation not enabled)
	stack traceback:
			[C]: in function 'error'
			./smalltemplate.lua:32: in function <./smalltemplate.lua:16>
			[C]: in function 'gsub'
			./smalltemplate.lua:38: in function 'template'
			./smalltemplate:20: in main chunk
			[C]: ?

If we fix this issue, here is what results:

	${} ./smalltemplate my_error_template_fixed.txt.lua
	(stderr) Templating my_error_template_fixed.txt.lua.  Allowing lua evaluation in template: false
	Here is my value, but it will no longer error, because I am using a lowercase V:

	'my value is here, but notice the lack of capital V for the variable name'

	(stderr) Templated my_error_template_fixed.txt.lua with 1 substitutions.

# Other things

Easter egg is enabled? ${easter_egg}]]

if variables.easter_egg then
    output = output .. [[


# Easter egg!

Hope you are doing well!  Happy Pride month from a fellow queer in 2023!  Hope
you are staying safe and full of pride!]]
end

return output,variables
