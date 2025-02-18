# Slicing a mesh by planes

Alejandro Morales

Centre for Crop Systems Analysis - Wageningen University

In this example we will learn how to use the slicer functionality to modify existing meshes
according to specific slicing planes. The idea of the slicer is to cut a mesh by one or
more planes, generating a new version of the mesh such that none the triangles intersect
with the planes. For example, if we use multiple horizontal planes (to define layers in the
soil or aboveground) this wil result in any triangle in the new mesh belonging to only one
layer. The slicer can be used when modeling plant-environment interactions, since the physics
of the environment will often be simulated in layers or voxels, though the user is free to
apply in other contexts.

To introduce the use of the slicer, we will first create a simple mesh and then slice it
using a single plane. A more detailed example will be provided in the next section.

## Slicing a rectangle with a single plane

Let's start by creating a simple rectangle.

```julia
using VirtualPlantLab
r = Rectangle(length = 1.0, width = 1.0)
```

We can check that the rectangle is implemented as two triangles:

```julia
ntriangles(r)
```

Now we will slice it by a horizontal plane at 0.5 units above the origin. We will use the
function `slice!` and specify the plane as `Z = 0.5`:

```julia
slice!(r, Z = 0.5)
```

We can check that the rectangle has been sliced into six triangles (each of the original
triangles has been split into three):

```julia
ntriangles(r)
```

The slicer adds a property `slices` to the mesh, which indicates to which layer or voxel
each triangle belongs to:

```julia
properties(r)[:slices]
```

As you can see, each triangle has been assigned three numbers, corresponding to the their
position relative to slicing planes perpendicular to the X, Y and Z axis respectively. A
`0` implies no actual slicing in a particular dimension (in this case both `X` and `Y`).
For `Z` axis, we have a `1` for the triangles below the slicing plane (first layer) and a
`2` for the triangles above the plane (second layer).

To visualize the results, let's color each triangle according to the layer it belongs to:

```julia
import ColorTypes: RGB
colors = [RGB(1, 0, 0), RGB(0, 1, 0)]
all_colors = RGB{Float64}[]
for slice in properties(r)[:slices]
    push!(all_colors, colors[slice[3]])
end
add_property!(r, :colors, all_colors)
```

And now we can render the results:

```julia
import GLMakie
render(r)
```

## Slicing a rectangle with multiple planes

Let's repeat the previous example but now we slice the rectangly with multiple planes along
the `Y` and `Z` axes. Note how we can pass an array of values to the `slice!` function:

```julia
r = Rectangle(length = 1.0, width = 1.0)
Ycuts = collect(-0.25:0.25:0.5)
ny = length(Ycuts)
Zcuts = collect(0.25:0.25:1)
nz = length(Zcuts)
slice!(r, Y = Ycuts, Z = Zcuts);
```

We now have a large number of triangles:

```julia
ntriangles(r)
```

We can visualize the results as before, assigning a random color to each pixel that results
from the intersection of the slicing planes. Notice that now we have to use the second and
third elements of the `slice` array to identify the exact location of the triangle in the
grid of pixels:


```julia
colors = rand(RGB, ny, nz)
all_colors = RGB{Float64}[]
for slice in properties(r)[:slices]
    push!(all_colors, colors[slice[2], slice[3]])
end
add_property!(r, :colors, all_colors)
render(r)
```

## Slicing geometry inside the `feed!` method

Using the slicer inside a `feed!` method is straightforward, though it requires some
adjustments. Firstly, we do not know a priori the number of triangles that will result from
the slicing, so we need to adjust the way we store colors or optical properties. Secondly,
we cannot add a geometric primitive directly to the turtle, as that will prevents use from
applying the slicer to it. Instead, we need to create a local version of the primitive,
slice it, add any properties we want to store (adjusting to the actual number of triangles)
and then feed it to the turtle using the more generic `Mesh!()`.

Let's illustrate this with an example reusing the rectangle we created before. This time
the rectangle represents the geometry of a node in a graph (e.g. a leaf of a plant or a soil
tile).

As usual, we create a module to contain the data structure and associated methods:

```julia
module MyRectangle
    using VirtualPlantLab
    import ColorTypes: RGB

    # Object that will be rendered as rectangle
    struct Tile <: Node
        length::Float64
        width::Float64
        colors::Matrix{RGB{Float64}}
    end

    function VirtualPlantLab.feed!(turtle::Turtle, t::Tile, data)
        # Create the rectangle
        r = Rectangle(turtle, length = t.length, width = t.width)
        # Slice it (YCUTS and XCUTS are global variables, could be in data too)
        slice!(r, Y = YCUTS, Z = ZCUTS)
        # Add the colors (the colors per pixel are stored in the node)
        all_colors = RGB{Float64}[]
        for slice in properties(r)[:slices]
            push!(all_colors, t.colors[slice[2], slice[3]])
        end
        # Add the mesh to the turtle while defining the colors as properties
        Mesh!(turtle, r, colors = all_colors)
        return nothing
    end

    # Define the cuts and functions to modify them
    YCUTS::Vector{Float64} = collect(-0.25:0.25:0.5)
    set_ycuts!(cuts) = (global YCUTS = cuts)
    ZCUTS::Vector{Float64} = collect(0.25:0.25:1)
    set_zcuts!(cuts) = (global ZCUTS = cuts)
end
```

Let's now create a simple static graph and make sure that we can generate the rectangular
tile:

```julia
import .MyRectangle as MR
nz = length(MR.ZCUTS)
ny = length(MR.YCUTS)
graph = Graph(axiom = MR.Tile(1.0, 1.0, rand(RGB, ny, nz)))
render(Mesh(graph))
```
