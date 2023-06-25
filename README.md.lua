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

# Escaping the `$` before `{`

To print a literal $ in the template, simply use this construct:

    ${}{}

The escape is only needed if the character after `$` is a `{`.  However, the
template function will naively replace all instances of `${}{}` with `$`.

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

# luajit issues when running with MSYS-MinGW

In MSYS-MinGW64, /usr/bin/luajit is a script with the following:

    $ cat /mingw64/bin/luajit
    #!/usr/bin/env bash
    /usr/bin/winpty "$( dirname ${}{BASH_SOURCE[0]} )/luajit.exe" "$@"

This means luajit will run using winpty, which if stdout or stderr is
redirected, it will fail to run with the following message:

    stdout is not a tty

There are two things you can do.

## Quick local fix

The quick an easy way is to change the line
at the top of `smalltemplate` from:

    #!/usr/bin/env luajit

to:

    #!/usr/bin/env luajit.exe

This will work, especially if you just need a local install script for your
templating.

## Fix for your user

The other option is to provide an alternate script in your PATH with the
following text:

    #!/bin/sh

    luajit.exe "$@"

Ensure it is executable (which in an MSYS-MinGW environment, it will
automatically be with the shebang line).  I put my scripts in ~/bin, and ensure
the following line is in ~/.bashrc:

    export PATH="$HOME/bin:$PATH"

Ensure your shell see it:

    $ which luajit
    /home/itchychips/bin/luajit

If it does not, and you are on bash, run `set +h` to forget remembered paths
for execution, and see if the script is seen.

Then, you should be able to run scripts with luajit and redirect the output for
more than just smalltemplate.

## See also

See these issues for the upstream MinGW-packages and winpty projects:

1. https://github.com/msys2/MINGW-packages/issues/949
2. https://github.com/rprichard/winpty/issues/73

# Other things

Easter egg is enabled? ${easter_egg}]]

if variables.easter_egg then
    output = output .. [[


# Easter egg!

Hope you are doing well!  Happy Pride month from a fellow queer in 2023!  Hope
you are staying safe and full of pride!]]
end

return output,variables
