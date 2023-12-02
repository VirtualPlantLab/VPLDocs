# Styling protocol

        Ana Ernst & Alejandro Morales
        Centre for Crop Systems Analysis - Wageningen University

A styling protocol is essential for code readability, consistency, and maintainability. It ensures that code follows predefined formatting rules, prevents errors, and suggests best practices for overall quality of the code. This type of protocol not only plays a crucial role in code quality but also when it comes to collaboration and long-term software project success.

This styling protocol was based on the [SciML Style Guide for Julia](https://docs.sciml.ai/SciMLStyle/stable/), adapted for the applications of VirtualPlantLab.

## Programming

This section outlines programming guidelines and best practices to ensure the quality, robustness, and maintainability of your codebase. These guidelines are essential for both the clarity of your code and the ease of collaboration with other users or developers.

* Defensive programming for public API only (not internal code)
        Defensive programming is a software development approach that focuses on 
        anticipating and handling possible errors and exceptions, as well as improve
        the reliability and robustness of the code.
            *For example, if one knows that a function `f(w0, w)` will have an error unless `w0 < p`, you can throw the function with a domain specific error: `throw(DomainError())`*
* Throw exceptions rather than `error("string")`
* Always use recipes and let the user load the Makie backend explicitly (but document this in tutorials)
* API must be documented using standard Julia docstrings (see templates)
* When in doubt, a submodule should become a package (see package protocol)
* Green [`@code_warntype`](https://docs.julialang.org/en/v1/manual/performance-tips/#man-code-warntype) for all functions
        In Julia, 'green' code indicates type-stability, which ensures better performance.
* Define accessor for all fields and document these rather than the fields themselves
        Accessors provides controlled access to data is important as it allows for future changes to the internal structure without affecting users that rely on accessors.
        *For example, in the [tutorial](https://virtualplantlab.com/stable/tutorials/Tree/Tree/) to build the representation of a 3D binary tree, we can set accessor functions as it follows*
        ````julia
        module TreeTypes
            import VirtualPlantLab
            # ... (previously defined types)
            # Accessor functions for treeparams parameters
            # Accessor for growth parameter
            function get_growth(params::treeparams)
                return params.growth
            end
            # ... (other previously defined functions)
        end
        ````

## General style

In this section, we outline the general style guidelines to maintain consistency and readability in your code. These guidelines are exemplified using the tree tutorial as a reference. However, if there is an acronym that is domain specific (e.g., LAI, SLA), it should be kept with the format - *Readability is the most important!*

* 4 spaces for indentation
* 92 character line length limits
* `CamelCase` for modules, structs and types
        For example:
        - `module TreeTypes ... end`
        - `struct Meristem <: VirtualPlantLab.Node end`
        - `Float64, Abstract64, ...`
* `snake_case` for functions and variables
        For example: `prob_break(bud)`
* `SNAKE_CASE` or `SNAKECASE` for constants
        For example: `CONSTANT, CONSTANT_A`  
* No Unicode in public APIs
        As code can interact with terminals without Unicode support, such as R or Python interfaces.
* `TODO` and `XXX` in comments for to do and broken code
* Inline comments if within 92 character rule
* Minimize whitespace, specially around brackets or certain operators.
        Recommended: `check, steps = has_descendant(node, condition = n -> data(n) isa TreeTypes.Meristem)` or `x^2`
        Not recommended: `check , steps = has_descendant ( node, condition = n -> data ( n ) isa TreeTypes.Meristem )` or `x ^ 2`
* Single empty line between functions and multiline blocks (not if they are one-liners)
* Function blocks end in `return`
* Ternary operator if within 92 character rule

**Modules**
---

- Module imports at the start of module, before any code (only use `import`)
- List multiple modules in a single line

**Functions**
---

- Short-form only if it fits within 92 characters
- Prefer to use keyword arguments instead of positional arguments (data as first argument)
- Use a named tuple for keyword arguments that are passed along to another method, rather than `kwargs...` (unless there is very little chance of ambiguity)
- Avoid type piracy and ambiguities (use [`Aqua.jl`](https://docs.juliahub.com/General/Aqua/0.5.1/)) 
- Basic rules for mutating functions (`!` and modify first argument)
- Prefer instances to types as arguments (BUT check with `@code_warntype` that inference is done correctly)
- Avoid one argument per line of code for functions that have a lot of arguments (an exception is the constructor for a model where each argument is a parameter with a default)
- Argument precedence: function > IO stream > mutated input > type > others
- Merge documentation of multiple methods if possible
- You can list `kwargs...` in the function signature and list the keyword arguments in the `docstring`


**VS Code Julia-specific syntax**
---

```yaml
{
    "[julia]": {
        "editor.detectIndentation": false,
        "editor.insertSpaces": true,
        "editor.tabSize": 4,
        "files.insertFinalNewline": true,
        "files.trimFinalNewlines": true,
        "files.trimTrailingWhitespace": true,
        "editor.rulers": [92],
        "files.eol": "\n"
    },
}
```

Use JuliaFormatter(link) with `style = "sciml"` (in the future and style for VPL will be formally defined) inside `.JuliaFormatter.toml` (at the root) then

```julia
using JuliaFormatter, SomePackage
format(joinpath(dirname(pathof(SomePackage)), ".."))
```
