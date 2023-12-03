# Package and Environment Management for VPL

Ana Ernst & Alejandro Morales  
Centre for Crop Systems Analysis - Wageningen University

This guide helps VPL users interested in (1) managing packages within the VPL-verse, (2) managing reproducible environments, and, (3) developing models into VPL-modules, customization, and extending VPL's functionality under their authorship. It equips them with essential Julia tools and functionalities to take control of these aspects, enhancing the VPL experience.

The guide introduces the user to the Julia programming language's package management system, [Pkg.jl](https://pkgdocs.julialang.org/v1/), explains its key features, and offers instructions on getting started  with Pkg, managing environments, adding, updating, and removing packages. It also delves into the concept of working with different environments and creating your own project environments. Furthermore, the document covers the process of generating files for new packages using [PkgTemplates.jl](https://github.com/JuliaCI/PkgTemplates.jl/) and demonstrates how to add dependencies and tests to a package. Information about package naming guidelines and VPL styling protocol, you can find it in [VPL styling protocol](). Finally, this guide provides general good practices to develop VPL packages.

# Introduction to Julia's packages and environments

Unlike traditional package managers, that install and manage a single global set of packages, [Pkg.jl](https://pkgdocs.julialang.org/v1/) does things differently, it uses **environments** - independent sets of packages that can be local to an individual project, and can be shared and selected by name.

In each of these environments, there is a neat list of the packages associated with the project and their exact versions, kept in a special file called `Manifest.toml`. You can check this file in the project repository and keep track of the versions of the different packages that you use on your project, significantly improving the reproducibility of projects.

So, if you ever want to work on a project from a different computer or share with with someone else, you can just bring back the environment using its manifest file. That way, you're all set with the right packages without any fuss.

Julia environments are *stackable* - you can overlay one environment with another and have access to additional packages outside of the original environment.
        
This makes it easy to work on a project, which provides the primary environment, while still having access from the REPL to all your usual dev tools like profilers, debuggers, and so on, just by having an environment including these dev tools later in the load path. 
        
So, it's like having your main work area and then, when needed, you can simply add more tools on top of it without disturbing your primary setup. This keeps things organized and makes it easy to switch between different tasks in Julia.             
 
## Getting started with Pkg.jl and environments

You can use Pkg.jl from the Julia REPL. You can start interfacing with `Pkg` by pressing `]` from the julia REPL. To get back to the julia REPL, press `Ctrl+C` or backspace.

* Use `add` command to install a package; ````(@v1.8) pkg> add VirtualPlantLab, Example````
* Use `up` command to update the installed packages; ````(@v1.8) pkg> up````
* Use `st` command to see installed packages; ````(@v1.8) pkg> st````
* Use `rm` command to remove a package; ````(@v1.8) pkg> rm VirtualPlantLab````
* Use `test` command to run the tests for a package; ````(@v1.8) pkg> test Example````

# Working with environments

To better understand how Julia works with environments, we have two different type of environments:

* **Project Environment**

It is a directory with a *project file* and a *manifest file*. A *project file* determines what are the names and identities of the direct dependencies of a project. A *manifest file* gives a complete dependency graph, including all direct and indirect dependencies, exact versions of each dependency, and sufficient information to locate and load the correct version.

These types of environments provide reproducibility. By storing a project environment in version control, such as a Git repository, along with the rest of project's source code, you can reproduce the exact state of the project and all of its dependencies. The manifest file, in particular, captures the exact version of every dependency, which makes it possible for Pkg to retrieve the correct versions and be sure that you are running the exact code that was recorded for all dependencies. These are fit to run your simulations, and share such files with others.

* **Package Directory**

It is directory that contains a tree of subdirectories, and forms an implicit environment. Each subdirectory contains a specific package - if the `X` is is a subdirectory of a package directory and `X/src/X.jl` exists, we can access to the package `X` from the package directory. 
        
Package directories are useful when you want to put a set of tools (in the format of packages) somewhere and be able to directly use them, without needing to create a project environment for them.

You can overlay these types of environments and obtained a **stacked environment** - an ordered set of project environments and package directories that make a single composite environment. The precedent and visibility rules combined determine which packages are available and where they get loaded from.

## Creating environments and using someone else's project

You may have noticed the `(@v1.8)` in the REPL prompt. So far we have added packages to the default environment at `~/.julia/environments/v1.8`. However, it is easy to create independent projects. This let us know that `v1.8` is the **active environment** - this is the environment that will be modified by `Pkg` commands above.

To set the active environment, you can use `activate`. In case this, we want to create a new active environment. `Pkg` will let us know that we are creating a new environment that will be stored in your `~/directory`.

````julia
(@v1.8) pkg> activate MyProject
Activating new environment at `~/MyProject/Project.toml`

(MyProject) pkg> st
Status `~/MyProject/Project.toml` (empty project)
````

Note that the REPL prompt changes when the new project is activated. Until a package is added, there are no files in this environment and the directory of this environment might not be created.

When you plan on using someone else's project, you can simply clone their project with `git clone`.

````julia
shell> git clone https://github.com/JuliaLang/Example.jl.git
Cloning into 'Example.jl'...
...
(@v1.8) pkg> activate Example.jl
Activating project at `~/Example.jl`
(Example) pkg> instantiate
No Changes to `~/Example.jl/Project.toml`
No Changes to `~/Example.jl/Manifest.toml`
````

If the project contains a `Manifest.toml` file, this will install the packages in the same state that is given by that manifest. If not, by default the latest versions of the dependencies compatible with the project will be installed.

The control **activate** by itself does not install missing dependencies. However, the control **instantiate** makes the environment ready to use:

* If you only have a `Project.toml` file, `instantiate` will generate a `Manifest.toml` file by 'solving' the environment, and all missing packages must be installed and precompiled.
* If you have `Project.toml` and `Manifest.toml`, `instantiate` ensures that the packages are installed with the correct versions
* If there is nothing to do, `instantiate` will do nothing

# Creating packages

## Generating files for a new package

The [PkgTemplates.jl](https://github.com/JuliaCI/PkgTemplates.jl) package offers an easy, repeatable, and customizable way to generate files for a new package. Likewise, usage is pretty straightforward. The following example includes the plugins suitable for a project hosted on GitHub, with some other customizations:

````julia
using PkgTemplates
t = Template(;
        user="my-username",
        dir="~/code",
        authors="author_name",
        julia=v"1.1",
        plugins=[
                License(; name="MPL"),
                Git(; manifest=true, ssh=true),
                GitHubActions(; x86=true),
                Codecov(),
                Documenter{GitHubActions}(),
                Develop()])
t("MyPkg")
````

Keyword arguments for `PkgTemplates.Template` object type:

* *User options:*
        * Github username: `user::AbstractString="username"` 
        * Package authors: `authors::Union{AbstractString, Vector{<:AbstractString}} = “name <email> and contributors”`
* *Package options:*
        * Directory where packages will be placed: `dir::AbstractString=”~/.julia/dev”`
        * Julia version: `julia::VersionNumber=v”1.0.0”`
* *Template plugins:* Plugins add functionality to `Templates`, as they automate common boilerplate takes related with generating package, in Github for this specific example.
        * List of plugins used by the template: `plugins::Vector{<:Plugin}=Plugin[]`

This creates a new package called `MyPkg`, with a new project `MyPkg.jl` in the subdirectory `src`. You can visualize directory structure with the `tree` command in the Julia REPL.

````julia
shell> tree MyPkg/
MyPkg/
├── Project.toml
├── Manifest.toml
└── src
        └── MyPkg.jl
2 directories, 3 files
````

The content of `src/MyPkg.jl` can be modified:

````julia
module MyPkg
#Add functions to the module
greet() = print(“Hello world!”)
end

pkg> activate ./MyPkg #Activate the project by using the path to the directory where it is installed
#Load the package
julia> import MyPkg
julia> MyPkg.greet()

Hello world!
````

## Styling guidelines

Package and function names should be sensible to most Julia users, even to those who are not domain experts. You can find the specifics in the [styling protocol]().

## Adding package dependencies

Back to `Pkg.jl`; let’s say we want to use a standard library package (e.g., `Random`) and a registered package (e.g. `JSON`). We simply add these packages.

````julia
(MyPkg) pkg> add Random JSON
Resolving package versions...
Updating `~/MyPkg/Project.toml`
[682c06a0] + JSON v0.21.3
[9a3f8284] + Random
Updating `~/MyPkg/Manifest.toml`
[682c06a0] + JSON v0.21.3
[69de0a69] + Parsers v2.4.0
[ade2ca70] + Dates
...
````

Both `Random` and `JSON` now got added to the project’s `Project.toml` file, and the resulting dependencies to the `Manifest.toml` file. We can now both use Random and JSON in our package, by changing `src/MyPkg.jl` again.

````julia
module MyPkg
#Importing packages
import Random
import JSON
#Add functions to the module
greet() = print("Hello World!")
greet_alien() = print("Hello ", Random.randstring(8))
end 
````

To reload a package in Julia without restarting the Julia session, you can use the [`Revise.jl`](https://timholy.github.io/Revise.jl/stable/) package whenever you want to work interactively and see immediate updates to your code.

````julia
using Revise #Important to load Revise.jl before your package
using MyPkg
#Now you can call the updated greet_alien() function
julia> MyPkg.greet_alien()

Hello aT157rHV
````

## Adding tests 

To add tests to a package, we have to (1) create a directory for tests, (2) create and write the script file, (3) execute tests.

````julia
#Create path to test directory
mkpath("MyPkg/test")
#Create simple test script file in MyPkg/test/runtests.jl
write("MyPkg/test/runtests.jl", 
        """
        #You can add specific tests here or edit seperatly the file itself
        println("Testing...")
        """);
#This command will run the tests specified in MyPkg/test/runtests.jl
(MyPkg) pkg> test
Testing MyPkg
Resolving package versions...
Testing...
Testing MyPkg tests passed
````

## Advanced considerations

Before formally registering your package, there are some more advanced nuanced issues that you may be concerned, namely compatibility and weak dependencies.

[**Compatibility:**](https://pkgdocs.julialang.org/v1/creating-packages/#Compatibility-on-dependencies)
        Ensuring compatibility involves the ability to restrict the versions of dependencies that your project can seamlessly work with. This includes configuring both test-specific and more general dependencies in the `Project.toml` file, allowing you to define precisely which versions are compatible.
[**Weak dependencies**](https://pkgdocs.julialang.org/v1/creating-packages/#Weak-dependencies)
        A weak dependency is a dependency that will not automatically install when the package is installed, but you can still control what versions of that package are allowed to be installed by setting compatibility on it. This can be set in the `Project.toml` file with conditional loading of the code.


# VPL packages

## General good practices

Use [`ArgCheck.jl`](https://github.com/jw3126/ArgCheck.jl) to perform checks on function arguments for public API (one may also use dedicated types to encapsulate these checks). VPL should have a strong preference for defensive programming even if this comes at the expense of runtime performance (but do try to avoid performance hits and repeating assertions).
        
````julia
#After installing ArgCheck - Pkg.add("ArgCheck")
using ArgCheck
#Example in function
function f(x,y)
@argcheck x < y
#The rest of the function
end

f(0,0)
ERROR: ArgumentError: x < y must hold. Got
x => 0
y => 0
````

* Try to achieve type stability, by using `@infered` in tests and statistically-size arrays, as often as possible.
* Avoid containers with abstract types.
* If you suspect that users may make mistakes, but still valid input is provided, please raise a warning.

**Documentation**
---

* Every single function/type exported requires a [`docstring`](https://docs.julialang.org/en/v1/manual/documentation/).
* For most docstrings, examples should be provided in the form of [jldoctests](https://documenter.juliadocs.org/stable/man/doctests/)
* Double check `docstring`s of functions that have been modified.
* `docsting`s maybe be provided if a function is not exported.

**Testing a package**
---

* Make sure that the tests include [`Aqua`](https://docs.juliahub.com/General/Aqua/0.5.1/). 
        Type piracy is allowed as long as the type is owned by a package in the VirtualPlantLab organization.
* All documentation should be written as `jldoctests` and the tests should include a call to `doctests`
* All functions in the source code should be tested individually (in many cases through their `jldoctests`)
* When relevant, type stability tests (`@inferred`) should be run on individual functions
        All types created for the tests should be included in a module and all tests should be run inside a (let … end) block.
* Test should cover 100% of source code (at least locally). The following is a template that can be used (normally located in a local dev folder not synced with Github):

````julia
# Run tests and collect statistics on code coverage
import Pkg
Pkg.test("PlantRayTracer", coverage = true)

# Process the coverage data using Coverage.jl
using Coverage
# process '*.cov' files
coverage = process_folder("src") # defaults to src/; alternatively, supply the folder name as argument
# process '*.info' files, if you collected them
coverage = merge_coverage_counts(coverage,
filter!(let prefixes = (joinpath(pwd(), "src", ""))
        c -> any(p -> startswith(c.filename, p), prefixes)
        end,
        LCOV.readfolder("test")))
# Get total coverage for all Julia files
covered_lines, total_lines = get_summary(coverage)
covered_lines / total_lines * 100 # 87%

# Clean up all the coverage files
clean_folder("src")
clean_folder("test")
````

**Updating an existing package**
---

All changes to a package should occur in a branch and a pull request should be used to request merging with the master branch. Merging should require CI to be successful. Increase the version number (see below for details) if one of the following is true:
* The changes break the API (check tutorials and tests of other packages to verify)
* The changes fix a significant bug
* Significant features have been added

Check that all the tests are successful in a dedicated module. This requires running `Pkg.test(<package>)` rather than running the `runtest.jl` file in Julia. This will tell you if there are any dependencies missing in the Project.toml of the tests. 
You may use the development version of a dependency while testing locally, but CI will fail until the changes in the dependency are registered.

*Increasing version number:*

* Increase the version number in the `Project.toml` file (not in git!)
* Go to the commit on Github with the changes in `Project.toml` file and add comment with `@JuliaRegistrator register`. This will trigger the registration bot which later will trigger the tagbot on Github. 
* Once the version on Github gets a new tag, synchronize the master branch of the local repository to get the same tag.
* You will need to update the dependencies of all other packages as otherwise the release versions of VPL will not work.

