# [Multiple dispatch and composition](@id manual_objets)

In this document we will learn how types and methods relate in Julia.

## Types

A type in Julia is a structure that collects related data and can be assigned specific
behavior (see below on *methods*). We create types using the `struct` keyword (with optional
modifiers) and listing the data fields that the type will contain (and we recommend to
include the type of data, for performance reasons).

For example, we can create types that represent leaves and fruits of a plant with some
basic properties.

```julia
struct Leaf
    length::Float64
    width::Float64
    weight::Float64
    color::String
end

struct Fruit
    radius::Float64
    weight::Float64
    color::String
end
```

We can create instances of these types:

```julia
L = Leaf(10.0, 5.0, 1.0, "green")
F = Fruit(1.0, 0.5, 1.0, "red")
```

All the data fields in a type are public by default, which means that we can access them
directly.

```julia
L.length
F.color
```

## Methods

Functions in Julia can be defined to operate on specific types of data if you annotate the
type of arguments in the function definition. For example, we can define a function to
calculate the surface area of a plant organ, but the formula to be used is different for
leaves and fruits. We could define two different functions, one for each type (e.g.,
`area_leaf` and `area_fruit`), but this would make the code more quite cumbersome and hard
to manage. Instead, we can define a single function `area` that will
behave differently depending on the type of the argument passed to it:

```julia
# Area of a leaf assuming an ellipse
function area(organ::Leaf)
    pi*organ.length*organ.width/4
end

# Area of a fruit assuming a sphere
function area(organ::Fruit)
    4*pi*organ.radius^2
end
```

We can now call the function `area` with either a leaf or a fruit and it will return the
correct area:

```julia
area(L)
area(F)
```

This is an example of *multiple dispatch*, which is a key feature of Julia. It allows us to
define functions that can operate on different types of data and have different behavior
depending on the type of the argument passed to it. The *dispatch* part means that the
call to the function `area` will be dispatched to the correct method based on the type of the
argument passed to it.

Dispatch will work on the combination of the types of all arguments, not just the
first one. For example, let's define two types of pests that can affect a plant, a larva that
can infest fruits and a caterpillar that can infest leaves. We want to test whether a particular
pest can infest a particular organ of the plant. We can define the types and methods as
follows:

```julia
struct Larva
end
struct Caterpillar
end
# Method to test whether a larva can infest an organ
infest(pest::Larva, organ::Fruit) = true
infest(pest::Larva, organ::Leaf) = false
# Method to test whether a caterpillar can infest an organ
infest(pest::Caterpillar, organ::Fruit) = false
infest(pest::Caterpillar, organ::Leaf) = true
```

Note that we did not add any fields to the pest types, as for now we are only interested in
whether they can infest a particular organ or not. Also, we are defining the methods using
a simpler syntax (without the `function` and `end` keyword) as they are quite simple.

Note that you can also define methods where the arguments are not annotated with specific
types. This will become a default method that will be called if the types of the arguments
do not match any of the the other methods. For example, we can add a default method that
returns `false` by default:

```julia
infest(pest, organ) = false
```

This means that if we call `infest` with a pest and an organ that are not
`Larva` or `Caterpillar` and `Fruit` or `Leaf`, respectively, it will return `false`. Of
course, we can add more specific methods later to handle other types of pests or organs.

Note that you can define methods for types that you did not create, not just for your
own types, even if they are stored in packages you downloaded from the internet. This
allows extending functionality of existing types and allows your own types to interact
with types defined by someone else.

Also, you can sometimes define types and methods that are meant to use by some algorithm in
a package, also extending the functionality of that package. For example, in VPL, you can
define types that are meant to be used as nodes in graphs and this can be achieved by simply
defining a couple of methods for specific functions defined in VPL (like the `feed!` method
to generate geometry). The flexibility of multiple dispatch is one of the key features of
Julia.

## Abstract types

Abstract types are an optional feature in Julia that allows implementing a reduced form of
*inheritance* in Julia. The idea is that one can define a method for an abstract type and
any type that inherits from that abstract type will match that method. Abstract types can
also inherit from other abstract types, allowing to create a hierarchy of types.

For example, we could define an abstract type `Organ` from which all plants organs will
inherit. Abstract types do not contain any data and we cannot create instances of them,
they are really just tags for asigning methods. Inheritance is indicated with
the symbol `<:` after the name of the type.

Let's create a new version of the `Leaf` and `Fruit` types that inherit from an `Organ`
abstract type. Unfortunately, Julia does not allow redefining types (unless you put them
in a module and import said module, we will do this in the VPL tutorials), so we will just
call them `Leaf2` and `Fruit2` for the purpose of this example:

```julia
abstract type Organ end

struct Leaf2 <: Organ
    length::Float64
    width::Float64
    weight::Float64
    color::String
end

struct Fruit2 <: Organ
    radius::Float64
    weight::Float64
    color::String
end
```

We could now define a method that operates on any organ, regardless of its type,
for example, to extract the color of the organ:

```julia
get_color(organ::Organ) = organ.color
```

And we can call it with any organ type that inherits from `Organ`:

```julia
L2 = Leaf2(10.0, 5.0, 1.0, "green")
F2 = Fruit2(1.0, 0.5, 1.0, "red")
println("Leaf2 color: ", get_color(L2))
println("Fruit2 color: ", get_color(F2))
```

Note that if we now define a method of `get_color` for `Leaf2` or `Fruit2`, it will
override the method for `Organ` and that one will be called instead. That is, the method
defined for the abstract type will be called only if there is no more specific method
defined for the concrete type. Abstract types and inheritance are not as important in Julia
as in traditional object-oriented programming languages.

In the context of VPL, you will need to define some types to extend the functionality of the
package and in those cases you will need to inherit from specific abstract types defined in
VPL. For example, when defining your own type of data structures to be used as node in
dynamic graphs (see tutorials for examples) those types will need to inherit from the
`Node` abstract type defined in VPL. This allows the internal code for graph rewriting to
handle objects defined by the user (which are obviously not known by the VPL developers
ahead of time).

In addition, the user will have to define specific methods for their data structures that
are expected by the VPL
in order for their internal algorithms to work properly. This is known as an *interface*
and it is a common practice in Julia programming. For example, in the most common version
of FSP models built with VPL, the user will have to define data types that inherit from
`Node` and define a method for the `feed!` function that generates the geometry associated
to each type of node. If you omit the `feed!` method, you will still be able to use those
types as nodes in the dynamic graphs but they will not generate any geometry (which in some
cases it may be what you want).

## Composition

In the previous sections we have seen how to define types and methods in Julia, as well as
how to use abstract types to create a hierarchy of types. These two approaches allow for
reuse of methods for multiple types (that share the same abstract type) as well as extending
code to work with new types. However, the methods that are being reused expected certain
data to be expected in the type. For example, the `get_color` method above expects that the
type has a `color` field, otherwise it will throw an error. There is therefore a need to
reuse data as well, not just methods. This is where *composition* comes into play.

Composition is a design principle in which a complex object is composed of simpler objects.
The idea is that the simpler objects implement a specific functionality with associated data
such that we can add functionality to a type by composing it with other types. Let's define
the functionality *growth* that will confer any organ the ability to grow. We will assume
a logistic growth model, where current growth rate is proportional to the current weight. We
thus need to keep track of the current weight, the maximum weight that the organ can attain
and the relative growth rate. We can define a type that implements this functionality as follows:

```julia
mutable struct Growth
    weight::Float64 # Current weight of the organ
    max_weight::Float64 # Maximum weight of the organ
    rgr::Float64 # Relative growth rate
end
```

Note that we added the `mutable` keyword to the type definition, which means that
instances of this type can be modified after they are created. This is important because
we will need to update the current weight of the organ as it grows. We can then define a
method that will update the current weight of the organ based on the
growth rate and the maximum weight:

```julia
function grow!(growth::Growth)
    if growth.weight < growth.max_weight
        growth.weight += growth.rgr*growth.weight*(1 - growth.weight/growth.max_weight)
    end
    return nothing
end
```

Note that we modify the `weight` field of the `growth` instance in place, which is
possible because we defined the type as `mutable`. The `grow!` function will not return
anything, it will just update the `weight` field of the `growth` instance.

We can now define new types of leaves and fruits that will have the ability to grow by
composing them with the `Growth` type. As explained before, we need to define new types
because we did not put them in their own module and import it:

```julia
struct Leaf3 <: Organ
    length::Float64
    width::Float64
    color::String
    growth::Growth # Composition with Growth type
end
struct Fruit3 <: Organ
    radius::Float64
    color::String
    growth::Growth # Composition with Growth type
end
```

Note how we have replaced the previous `weight` field with a `growth` field that
contains an instance of the `Growth` type. We can now create instances of `Leaf3` and `Fruit3`
and pass an instance of `Growth` to them:

```julia
L3 = Leaf3(10.0, 5.0, "green", Growth(1.0, 0.1, 0.1))
F3 = Fruit3(1.0, "red", Growth(1.0, 0.2, 0.1))
```

Of course our types would need to be improved as their dimensions are now decoupled from the
weight of the organ itself, but remember that this is just an example to illustrate features
of the Julia language and in a real model we would later add changes to the types as needed
(in fact, you are likely to develop models in this iterative, dynamic way, rather than
figure everything out ahead of time). We can now call the `grow!` method on the
`growth` field of the `Leaf3` and `Fruit3` instances to update their
current weight:

```julia
grow!(L3.growth)
grow!(F3.growth)
```

And the weight of the organs will be updated accordingly. We can access the current weight
of the organs by accessing the `weight` field of the `growth` field:

```julia
L3.growth.weight
F3.growth.weight
```

## Method forwarding

We have seen how to compose types in Julia to add functionality to them. However, this
means that we need to access the methods of the composed type through the field name, which
can be cumbersome. For example, we need to call `grow!(L3.growth)`
to grow the leaf, which is not very intuitive. We can use *method forwarding* to
make this more intuitive. Method forwarding is a technique that allows us to define methods
that forward the call to the method of the composed type. For example, we can define a
method for the `grow!` function that forwards the call to the `growth` field of the organ.
We can define this method per organ type or, if we expect all organs to grow, we can define
it for the abstract type `Organ` so that all organs will have the same behavior:

```julia
function grow!(organ::Organ)
    grow!(organ.growth)
end
```

Now we can call `grow!(L3)` and `grow!(F3)` to grow the leaf and the fruit, respectively:

```julia
grow!(L3)
grow!(F3)
```

Here we are using multiple dispatch and inheritance to use the `grow!` method on all organs
while relying on type composition to implement the actual growth functionality. If you need
to forward many methods you may want to use a macro to automate the process or use existing
packages that already implement such macros (e.g., `MethodForwarding.jl` or `ForwardMethods.jl`).

At this point you may be wondering why we did not just define the `grow!` method
directly in the `Leaf3` and `Fruit3` types. The reason is modularity. By separating the
data structures and methods according to functionality, we can encapsulate the relevant code
and make it easier to use, without necessarily having to know all the details. This approach
is currently being used in the VPLverse package `Ecophys.jl`, where data structures for, for
example, photosynthesis are defined with associated methods. Thus, adding the ability to
photosynthesize to a plant organ is as simply as adding one of the relevant data types from
`Ecophys.jl` and calling the relevant method.

## About object-oriented programming

If one searches online whether Julia implements object-oriented programming (OOP), the results
will be mixed as it depends entirely on how does one define OOP.
If the definition matches what is understood by OOP in languages
such as C++, Java or Python (i.e. *classic* OOP), then the answer is simply no. The reason for this is that:

- Julia only allows inheritance from abstract types. This means that concrete types in
  Julia can inherit methods from their parent types but not data.
- Data types in Julia encapsulate data but not methods (i.e., objects in Julia do not own
  methods).

If one defines OOP as a paradigm that requires encapsulation of data
(but not necessarily methods) and inheritance of methods (but not necessarily data) then
the approach used in Julia and described above would qualify as OOP.
That is, the answer to whether Julia implements OOP depends entirely
on how one defines the paradigm and there is simply no right or wrong way of defining concepts.

If you are transitioning form a language with *classic* OOP  you will need
to rethink how to organize your code if you want to stick to a *Julian* way of programming.
Essentially you should replace inheritance of data with object composition (plus optionally
method forwarding) and use multiple method dispatch for functionality (what in *classic* OOP
would be *interfaces*). Searching online for *composition over inheritance* may help with
the transition (e.g., https://en.wikipedia.org/wiki/Composition_over_inheritance).
