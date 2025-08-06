# [Modules and files](@id manual_modules)

In this document we will learn how VPL code can be organized into files and modules.

## Files

Julia code can be organized into files, which are plain text files with a `.jl` extension.
A file can contain multiple functions, types, and variables. We can load the code from a
file using the `include` function. For example, if we have a file named `my_functions.jl`
that contains the following code, we can load this file into the current Julia session using:

```julia
include("my_functions.jl")
```

This will simply execute the code in the file, so it is equivalent to copying and pasting
the code into the current session.

When developing a VPL model you want to be able to makes changes to the code and run it without
having to restart the Julia session. For functions this is not really an issue but redefinition
of types (`struct` or `mutable struct`) is not allowed in Julia within the same session. To
bypass this we need to use the following strategy:

- Make sure that the package `Revise.jl` is installed and loaded.
- Use `includet` instead of `include` to load files.
- Place all type definitions and global variables inside one or more modules.

This means that, when building a typical VPL model, you should include at least one module
to host the type definitions for the different organs in your model. Of course, for large
models you may want to consider splitting your code into multiple files and modules
to keep it organized and manageable.

Note that there are alternative ways to bypass the type redefinition issue, such as using the
[`ProtoStruct.jl`](https://github.com/BeastyBlacksmith/ProtoStruct.jl) package.

## Modules

In Julia, a module is a collection of related functions, types, and variables that can be
grouped together to form a namespace. Modules help in organizing code and avoiding name
clashes. A module can be defined using the `module` keyword, and it can export specific
functions or types to make them available outside the module.

For example, the following code defines a simple module named `MyModule` that exports a function
`my_function`:

```julia
module MyModule

export my_function

function my_function(x)
    return x + 1
end

end
```

We can refer to the name of the module as `.MyModule` where the `.` indicates that it is a
local module defined in the current scope (Julia packages also defined modules, but they are
not prefixed with a `.`).

```julia
using .MyModule
result = my_function(5)  # This will return 6
```

Modules can also be nested, allowing for better organization of code. For example, we can define
a module `OuterModule` that contains another module `InnerModule`:

```julia
module OuterModule
    module InnerModule
        export inner_function
        function inner_function(x)
            return x * 2
        end
    end  # End of InnerModule
    export outer_function
    function outer_function(x)
        return x + 2
    end
end  # End of OuterModule
```

We can use the nested module as follows (not that `.` is used to separated nested modules):

```julia
using .OuterModule.InnerModule
result_inner = inner_function(3)  # This will return 6
using .OuterModule
result_outer = outer_function(3)  # This will return 5
```

The keyword `using` will make available all exported functions and types from the module,
while `import` will only make the module available without importing its exported functions
or types. This allows for more control over what is imported into the current namespace but
we need to prefix each function or type with the module name to use it:

```julia
import .OuterModule.InnerModule
result_inner = OuterModule.InnerModule.inner_function(3)  # This will return 6
result_outer = OuterModule.outer_function(3)  # This will return 5
```

If the name of the module is too long or cumbersome, we can use the `as` keyword to
create an alias for the module:

```julia
using .OuterModule.InnerModule as Inner # Now Inner refers to OuterModule.InnerModule
result_inner = Inner.inner_function(3)  # This will return 6
```

Also, we can import specific functions or types from a module using the `import` keyword:

```julia
import .OuterModule.InnerModule: inner_function
result_inner = inner_function(3)  # This will return 6
```

A Julia source file can contain multiple modules, but a module can only be defined within a
single source file.

### Defining methods for existing functions

If you want to add a method to an existing function so that it works with a new type (e.g.,
the `feed!` methods that are used in VPL to generate geometry), you need to define the
method by prefixing the function name with the module name where the function is defined.
As you will see in the tutorials, this means we define `feed!` methods as follows:

```julia
function VirtualPlantLab.feed!(turtle::Turtle,, ...)
    # Implementation of the method
end
```

It is important to do this to make sure that we are creating a method for the `feed!` function
even if you used `using VirtualPlantLab`.

## How to organize your code

VPL models can become quite complex, depending on how much functionality is added. There is
no correct way to organize your code into multiples files and modules but it helps to think
for a bit why do we even want to do this (i.e., as said before, you probably want to have
at least one modules for your organ types but you could write an entire model in a single
file, as in the tutorials in this website).

We generally want to have multiple files to make sure that, when we are editing a particular
aspect of the code, we visit as few files as possible. The reason for this is that it is
always easier to search within a single file and to jump up and down in the code than to
switch files (though searching across files is also possible in most editors).

We also want to have multiple files if we expect to reuse some of the code for other models
or simpler version of our current model. This touches on the issue of modularity, whereby
we want to organized different parts of the code that can be reused in different contexts.

Regarding modules, the main reason for their use (besides what was described earlier about
types) is to avoid clashes between function names and global variables. This is very much
related to the issue of modularity, as we want to be able to reuse code without worrying
about having to rename functions or variables inside the code (i.e., a module helps build
the abstraction of a *black box* that can be used without knowing its internal details).
This may never be required in small models (or even in large models that are not meant
to be reused), so just use your own judgement to decide how to organize your code based on
your specific needs.
