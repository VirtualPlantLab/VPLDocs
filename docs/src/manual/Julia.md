# [Julia basic concepts](@id manual_julia)

Alejandro Morales

Centre for Crop Systems Analysis - Wageningen University


# Introduction

This is not a tutorial or introduction to Julia, but a collection of basic
concepts about Julia that are particularly useful to understand VPL.  It is
assumed that the reader has some  experience with programming in other languages,
such as Matlab, R or Python. These concepts should be complemented with general
introductory material about Julia, which can be found at the official
[Julia website](https://julialang.org/).

Julia is a dynamic, interactive programming language, like Matlab, R or Python.
Thus, it is very easy to use and learn incrementally. The language is young and
well designed, with an emphasis on numerical/scientific computation although it
is starting to occupy some space in areas such as data science and machine
learning. It has a clear syntax and better consistency than older programming
languages.

Unlike Matlab, R or Python, Julia was designed from the beginning to be fast (as
fast as statically compiled languages like C, C++ or Fortran). However, achieving
this goal does require paying attention to certain aspects of the language, such
as *type stability* and *dynamic memory allocation*, which are not always obvious
to the user coming from other scientific dynamic languages. In the different
sections below, a few basic Julia concepts are presented, first by ignoring
performance considerations and focusing on syntax, and then by showing how to
improve the performance of the code. Some concepts are ignored as they are not
deemed relevant for the use of VPL.

# Running Julia

There are different ways of executing Julia code (most popular ones are VS Code
and Jupyter notebook):

* Interactive Julia console from terminal/console (REPL)
* Plugins for code editors
    * Visual Studio Code (most popular)
    * Atom/Juno (less popular now)
    * vim, Emacs and others (less popular)
* Code cells inside a Jupyter notebook
* Code cells inside Pluto notebook (a Julia implementation of a reactive notebook)

The first time in a Julia session that a method is called it will take extra
time as the method will have to be compiled (i.e. Julia uses a Just-in-Time
compiler as opposed to an interpreter). Also, the first time you load a package
after installation/update it will take extra time to load due to precompilation
(this reduces JIT compilation times somewhat). Also, code editors and notebooks
may need to run additional code to achieve their full functionality, which may
add some delays in executing the code.

# Basic concepts

## Functions

A function is defined with the following syntax.
```julia
function foo(x)
    x^2
end
foo(2.0)
```

Very short functions can also be defined in one line

```julia
foo2(x) = x^2
```

```julia
foo2(2.0)
```

Functions can also be defined with the "$\to$" syntax. The result can be assigned to any variable.

```julia
foo3 = x -> x^2
```

```julia
foo3(2.0)
```

A `begin` - `end` block can be used to store a sequence of statements in multiple lines and assign them to "short function or a "$\to$ function.

```julia
foo4 = begin
    x -> x^2
end
```

```julia
foo4(2.0)
```

Once created, there is no difference among `foo`, `foo2`, `foo3` and `foo4`.

Anonymous functions are useful when passing a function to another function as argument. For example, the function `bar` below allows applying any function `f` to an argument `x`. In this case we could pass any of the variables defined above, or just create an anonymous funcion in-place.

```julia
function bar(x, f)
    f(x)
end
bar(2.0, x -> x^2)
```

## Types

A Type in Julia is a data structure that can contain one or more fields. Types are used to keep related data together, and to select the right method implementation of a function (see below). It shares some of the properties of Classes in Object-Oriented Programming but there are also important differences.

Julia types can be immutable or mutable.

Immutable means that, once created, the fields of an object cannot be changed. They are defined with the following syntax:

```julia
struct Point
  x
  y
  z
end
```

```julia
p = Point(0.0, 0.0, 0.0)
```

```julia
p.x = 1.0
```

Mutable means that the fields of an object can be modified after creation. The definition is similar, just needs to add the keyword `mutable`

```julia
mutable struct mPoint
  x
  y
  z
end
```

```julia
mp = mPoint(0.0, 0.0, 0.0)
```

```julia
mp.x = 1.0
mp
```

We can always check the type of an object with the function `typeof`

```julia
typeof(p)
```

If you forget the fields of a type, try to using `fieldnames` in the type (not the object). It will return the name of all the fields it contains (the ":" in front of each name can be ignored)

```julia
fieldnames(Point)
```

Note that, for performance reasons, the type of each field should be annotated in the type definition as in:
```julia
struct pPoint
  x::Float64
  y::Float64
  z::Float64
end
pPoint(1.0, 2.0, 3.0)
```

Also, note that there are no private fields in a Julia type (like Python, unlike C++ or Java).

## Methods

Methods are functions with the same name but specialized for different types.

Methods are automatically created by specifying the type of (some of) the arguments of a function, like in the following example

```julia
function dist(p1::pPoint, p2::pPoint)
    dx = p1.x - p2.x
    dy = p1.y - p2.y
    dz = p1.z - p2.z
    sqrt(dx^2 + dy^2 + dz^2)
end
```

```julia
p1 = pPoint(1.0, 0.0, 0.0)
p2 = pPoint(0.0, 1.0, 0.0)
dist(p1, p2)
```

Note that this function will not work for `mPoint`s

```julia
mp1 = mPoint(1.0, 0.0, 0.0)
mp2 = mPoint(0.0, 1.0, 0.0)
dist(mp1, mp2)
```

So we need to define `dist` for `mPoint` as arguments, or use inheritance (see below).

## Abstract types

Types cannot inherit from other types.

However, when multiple types share analogus functionality, it is possible to group them by "abstract types" from which they can inherit. Note that abstract types do not contain any fields, so inheritance only works for methods. "abstract types are defined by how they act" (C. Rackauckas)

For example, we may define an abstract type `Vec3` defined as any type for which a distance (`dist`) can be calculated. The default implementation assumes that the type contains fields `x`, `y` and `z`, though inherited methods can always be overriden.

Inheritance is indicated by the "<:" syntax after the name of the type in its declaration.

```julia
# Vec3 contains no data, but dist actually assumes that x, y and z are fields of any type inheriting from Vec3
abstract type Vec3 end
function dist(p1::Vec3, p2::Vec3)
    dx = p1.x - p2.x
    dy = p1.y - p2.y
    dz = p1.z - p2.z
    sqrt(dx^2 + dy^2 + dz^2)
end
# Like before, but inhering from Vec3
struct Point2 <: Vec3
  x::Float64
  y::Float64
  z::Float64
end
mutable struct mPoint2 <: Vec3
  x::Float64
  y::Float64
  z::Float64
end
struct Point3 <: Vec3
  x::Float64
  y::Float64
end
```

The method now works with `Point2` and `mPoint2`
```julia
p1 = Point2(1.0, 0.0, 0.0)
p2 = Point2(0.0, 1.0, 0.0)
dist(p1, p2)
mp1 = mPoint2(1.0, 0.0, 0.0)
mp2 = mPoint2(0.0, 1.0, 0.0)
dist(mp1, mp2)
```

The method will try to run with `Point3` but it will raise an error because
`Point3` does not have the field `z`.

```julia
p3 = Point3(1.0, 0.0)
dist(p1, p3)
```

### Optional and keyword arguments

Functions can have optional arguments (i.e. arguments with default values) as well as keyword arguments, which are like optional arguments but you need to use their name (rather than position) to assign a value.

An example of a function with optional arguments:

```julia
opfoo(a, b::Int = 0) = a + b
opfoo(1)
```

```julia
opfoo(1,1)
```

An example of a function with keyword arguments

```julia
kwfoo(a; b::Int = 0) = a + b
kwfoo(1)
```

```julia
kwfoo(1, b = 1)
```

## Modules

Within a Julia session you cannot redefine Types. Also, if you assign different data to the same name, it will simply overwrite the previous data (note: these statements are simplifications of what it actually happens, but it suffices for now).

To avoid name clashes, Julia allows collecting functions, methods, types and abstract types into Modules. Every Julia package includes at least one module.

A module allows exporting a subset of the the names defined inside of it:

```julia
module Mod

export fooz

fooz(x) = abs(x)

struct bar
   data
end

end
```

In order to use a module the `using` command must be used (the `.` is required and
indicates that the module was defined in the current scoppe, as modules can be
nested).

```julia
using .Mod
```

Exportednames can be used directly

```julia
fooz(-1)
```

Unexported names can still be retrieved, but must be qualified by the module name.

```julia
b = Mod.fooz(-1.0)
```

## Adding methods to existing functions

If a function is defined inside a module (e.g., a Julia package) we can add
methods to that function by accessing it through the module name. Let's define a
function `abs_dist` that calculates the Manhattan (as opposed to Euclidean)
distance between two points. We will put it inside a module called `Funs` to
emulate a Julia package.

```julia
module Funs
  export manhattan
  function manhattan(p1, p2)
      dx = p1.x - p2.x
      dy = p1.y - p2.y
      dz = p1.z - p2.z
      abs(dx + dy + dz)
  end
end
using .Funs
manhattan(p1, p2)
manhattan(p1, p3)
```

We see that we have the same error as before when using `p3`. Let's add methods
for when one the first or second argument is a `Point3` that ignores the `z`:

```julia
Funs.manhattan(p1::Point3, p2) = abs(p1.x - p2.x + p1.y - p2.y)
Funs.manhattan(p1, p2::Point3) = abs(p1.x - p2.x + p1.y - p2.y)
manhattan(p1, p3)
manhattan(p3, p1)
```

You can find all the methods of a function by using `methods()` on the function
name:

```julia
methods(manhattan)
```

## Macros

A macro is a function or statement that starts with `@`. The details of macros are not explained here, but it is important to know that they work by **modifying the code** that you write inside the macro, usually to provided specific features or to achieve higher performance. That is, a macro will take the code that you write and substitute it by some new code that then gets executed.

An useful macro is `@kwdef` provided by the module `Base`, which allows assigning default values to the fields of a type and use the fields as keyword arguments in the constructors. This macro needs to be written before the type definition. For example, a point constructed in this manner would be:

```julia
Base.@kwdef struct kwPoint
    x::Float64 = 0.0
    y::Float64 = 0.0
    z::Float64 = 0.0
end
kwPoint()
kwPoint(1,1,1)
kwPoint(y = 1)
```

## Dot notation

Dot notation is a very useful feature of Julia that allows you to apply a function
to each element of a vector. For example, if you want to calculate the square of
each element of a vector you can do:

```julia
x = [1,2,3]
y = x.^2
```

The dot notation can be used with any function, not just mathematical functions.
For example, if you want to calculate the absolute value of each element of a
vector you can do:

```julia
abs.(y)
```

If the operation is more complex, the '.' should be used in all the steps or,
alternatively, use the macro `@.` that does the same:

```julia
abs.(y) .+ x.^3
@. abs(y) + x^3
```

The dot notation can also be used with functions that take more than one argument,
but make sure that all the arguments have the same length
```julia
min.(x, y)
max.(x, y)
```

# Improving performance

## Type instability

As indicated above, annotating the fields of a data type (`struct` or `mutable struct`) is
required for achieve good performance. However, neither arguments of functions nor variables
created through assignment require type annotation. This is because Julia uses
type inference (i.e. it tries to infer the type of data to be stored in each newly
created varaible) and compiles the code to machine level based on this inference.
This leads to the concept of *type instability*: if the type of data stored in a variable
changes over time, the compiler will need to accomodate for this, which results
(for technical reasons beyond the scope of this document) in a loss of performance.

Here is a classic example of type instability. The following function will add
up the squares of all the values in a vector:

```julia
function add_squares(x)
  out = 0
  for i in eachindex(x)
    out += x[i]^2
  end
  return out
end
```
It looks innocent enough. The issue here is that `out` is initialized as an integer
(`0`), but then it is assigned the result of `sqrt(x)`, which may be a real value (e.g. `1.0`),
which would have to be stored as a floating point number. Because `out` has different
types at different points in the code, the resulting code will be slower than it could be,
but still correct (this is why Julia is useful for rapid code development compared
to static languages like C++ or Java).

```julia
add_squares(collect(1:1000)) # type stable
add_squares(collect(1:1000.0)) # not type stable
```

How do we measure performance then? The `@time` macro is useful for this if
dealing with a slow function. Otherwise it is better to use `@btime` from the
*BenchmarkTools* package (see documentation of the package to understand why
we use `$`).

```julia
using BenchmarkTools
v1 = collect(1:1000)
v2 = collect(1:1000.0)
@btime add_squares($v1)
@btime add_squares($v2)
```

The second code is 12 times slower than the first one. We can detect type instability
by using the `@code_warntype` macro. This macro will print a internal representation
of the code before it is compiled. The details are complex, but you just need to
look for things in red (which indicate type instability).

```julia
@code_warntype add_squares(v1)
@code_warntype add_squares(v2)
```

How do we fix this? We could write different methods for different types of x,
but this is not very practical. Instead, we can use the `zero()` function combined
with `eltype()` to initialize `out` with the correct type.

```julia
function add_squares(x)
  out = zero(eltype(x)) # Initialize out with the correct type with value of zero
  for i in eachindex(x)
    out += x[i]^2
  end
  return out
end
```

You could also initialize out to the first element of x and iterate over the rest
of the elements, but this may not always possible (e.g. if `x` is empty or has
one value only), so the logic will get more complex.

Now the code is type stable:

```julia
@code_warntype add_squares(v1)
@code_warntype add_squares(v2)
```

And the performance is more similar:

```julia
@btime add_squares($v1)
@btime add_squares($v2)
```

## Performance annotations

Sometimes code can be annotated to improve performance. For example, the `@simd`
can be used in simple loops to indicate that the loop can be vectorized inside
the CPU (it allows to run simple CPU instructions on small sets of data simultaneously). The
`@inbounds` macro can be used to indicate that the code will not access elements
outside the bounds of an array.

```julia
function add_squares(x)
  out = zero(eltype(x)) # Initialize out with the correct type with value of zero
  @simd for i in eachindex(x)
    @inbounds out += x[i]^2
  end
  return out
end
@btime add_squares($v1)
@btime add_squares($v2)
```

Now we actually get faster performance for floating point number, which is related
to the fact that the CPU can vectorize floating point operations more efficiently
than integer operations (at least in this example). You can see the actual assembly
code being generated (or an approximation of it) by using the `@code_native` macro.
Any instruction that starts with `v` is a vectorized instruction. Note that
sometimes Julia will automatically vectorize code without the need for the `@simd`
but this is not always the case.

```julia
@code_native add_squares(v2)
```

Notice how with some simple annotations and reorganizing the code to deal with
type instability we were able to get a 30x speedup. Obviously this was a simple
function with minimal runtime, so the speedup is not particularly useful, but
this type of small functions are often the ones that are called many times in
complex computations (e.g., ray tracing), so the speedup can be significant in
actual applications. Whether you need to worry about performance depends on
where the bottleneck is in your code.

For more details, see the sections of the manual on [profiling](https://docs.julialang.org/en/v1/manual/profile/)
and [performance tips](https://docs.julialang.org/en/v1/manual/performance-tips/).

## Global variables and type instability

Global variables are any variable defined in a module outside of a function that is
accessed from within a function. Global variables are not recommended in general
as they can easily introduce bugs in your code by making the logic of the program
much harder to reason about. However, they can also introduce performance issues
as any global variable that is not annotated with its type will lead to type instability.

For example, let's say we modify the `add_squares` function to use a global variable
(a bit odd, but it is just to illustrate the point) to enable differen options in
the code.

```julia
function add_squares(x)
  out = zero(eltype(x))
  if criterion > 0
    @simd for i in eachindex(x)
      @inbounds out += x[i]^2
    end
  else
    @simd for i in eachindex(x)
      @inbounds out -= x[i]^2
    end
  end
  return out
end
criterion = 1
@code_warntype add_squares(v2)
@btime add_squares(v2)
```

It is not a major hit in performance as `criterion` is only accessed once, but
this can be a problem if the global variable is accessed many times in the code.
The short term solution is to annotate the type of the global variable (but really
we should be writing code without global variables). This can be frustating as
once a global variable is created, you cannot annotate its type (even if it does
not change!) without restarting the Julia session (unless it is inside a module).

```julia
function add_squares(x)
  out = zero(eltype(x))
  if criterion2 > 0
    @simd for i in eachindex(x)
      @inbounds out += x[i]^2
    end
  else
    @simd for i in eachindex(x)
      @inbounds out -= x[i]^2
    end
  end
  return out
end
criterion2::Int64 = 1
@code_warntype add_squares(v2)
@btime add_squares(v2)
```
