# Retrieving absolute coordinates

Alejandro Morales

Centre for Crop Systems Analysis - Wageningen University

In VPL, a turtle graphics approach is used to generate 3D geometry from graphs. In this
approach, geometry is generated locally relative to the current position and orientation
of the so-called turtle (inside `feed!()` methods specialized for each type of node by
the user). However, sometimes it is required to obtain the absolute coordinates and
orientation of a mesh in the scene. For example, the user may want to assign nitrogen
levels to a leaf based on its absolute position inside the canopy by assuming a
particular canopy nitrogen profile. Or we may want to know the angle of a branch with
respect to the horizontal plane (e.g., when studying gravitropism).

In this little guide we will show how to extract this information from the turtle inside
the `feed!()` method so that users can make use of this information. We will also show
how to retrieve the absolute coordinates of the triangles both from the turtle, a mesh
or a scene.

## Extracting state of the turtle

The turtle is defined by its position and three axes: `arm`, `up` and `head`. The
directions defined by these vectors correspond to the `width`, `height` (if present) and
`length` of geometry primitives. These geometry primitives are generated in front of the
turtle, starting at its current position. If a geometry primitive is added to the turtle
using the argument `move = true`, the turtle will move a distance `length` along the
`head` axis. From this information one can retrieve several properties of the generated
geometry (e.g., its center, orientation, etc.).

To retrieve the state of the turtle we use the methods `pos`, `arm`, `up` and `head`.
Let's illustrate this with a modified version of the [Tree tutorial](https://virtualplantlab.com/dev/tutorials/from_tree_forest/tree/) where we will
calculate the location and inclination angle (with respect to the horizontal plane) of
each leaf.

Let's start with the definition of the types required to build a tree:

```julia
using VirtualPlantLab
using ColorTypes: RGB
import GLMakie
using Plots
import Random: seed!
import Statistics: mean
using StatsPlots

module TreeTypes
    import VirtualPlantLab as VPL
    # Meristem
    struct Meristem <: VPL.Node end
    # Bud
    struct Bud <: VPL.Node end
    # Node
    struct Node <: VPL.Node end
    # BudNode
    struct BudNode <: VPL.Node end
    # Internode (needs to be mutable to allow for changes over time)
    Base.@kwdef mutable struct Internode <: VPL.Node
        length::Float64 = 0.10 # Internodes start at 10 cm
    end
    # Leaf
    Base.@kwdef mutable struct Leaf <: VPL.Node
        length::Float64 = 0.20 # Leaves are 20 cm long
        width::Float64  = 0.1  # Leaves are 10 cm wide
        height::Float64 = 0.0  # Height of the center of the leaf
        angle::Float64  = 0.0  # Angle of the leaf with respect to the horizontal plane
    end
    # Graph-level variables
    Base.@kwdef struct treeparams
        growth::Float64 = 0.1
        phyllotaxis::Float64 = 140.0
        leaf_angle::Float64 = 30.0
        branch_angle::Float64 = 45.0
    end
end
import .TreeTypes
```

We now define the `feed!()` methods for each type of node. Inside these methods we will
calculate the absolute height and inclination angle of each leaf and store it inside the
corresponding leaf node

```julia
function VirtualPlantLab.feed!(turtle::Turtle, i::TreeTypes.Internode, vars)
    # Rotate turtle around the head to implement elliptical phyllotaxis
    rh!(turtle, vars.phyllotaxis)
    HollowCylinder!(turtle, length = i.length, height = i.length/15, width = i.length/15,
                move = true, colors = RGB(0.5,0.4,0.0))
    return nothing
end

# Create geometry + color for the leaves
function VirtualPlantLab.feed!(turtle::Turtle, l::TreeTypes.Leaf, vars)
    # Rotate turtle around the arm for insertion angle
    ra!(turtle, -vars.leaf_angle)
    # Extract the position of the turtle and the head vector
    t_pos = pos(turtle)
    t_head = head(turtle)
    # The center of the leaf is length/2 in front of the turtle
    center = t_pos .+ 0.5*l.length*t_head
    l.height = center[3] # Height is the z-coordinate of the center
    # The inclination angle of the leaf is the same as the zenith angle of the up vector
    # This is given by the arc-cosine of the vertical component
    l.angle = acos(up(turtle)[3])*180/π # Convert to degrees
    l.angle = l.angle > 90 ? 180.0 - l.angle : l.angle  # Correct for the angle being > 90
    # Now we generate the leaf
    Ellipse!(turtle, length = l.length, width = l.width, move = false,
             colors = RGB(0.2,0.6,0.2))
    # Rotate turtle back to original direction
    ra!(turtle, vars.leaf_angle)
    return nothing
end

# Insertion angle for the bud nodes
function VirtualPlantLab.feed!(turtle::Turtle, b::TreeTypes.BudNode, vars)
    # Rotate turtle around the arm for insertion angle
    ra!(turtle, -vars.branch_angle)
end
```

We can see that the location and inclination of the leaf is calculated from the turtle's
state inside the `feed!()` method and store in the leaf node as a side effect. This is
important as we will not have updated information about the leaves until the scene is
generated. Let's now add the rules for the tree growth (we ignore the more complex
bud break rule that was used in the original tutorial and just break each bud with a
probability of 25% assuming an uniform distribution):

```julia
meristem_rule = Rule(TreeTypes.Meristem,
                     rhs = mer -> TreeTypes.Node() +
                                    (TreeTypes.Bud(), TreeTypes.Leaf()) +
                                     TreeTypes.Internode() + TreeTypes.Meristem())
branch_rule = Rule(TreeTypes.Bud,
            lhs = bud -> rand() <= 0.25,
            rhs = bud -> TreeTypes.BudNode() + TreeTypes.Internode() + TreeTypes.Meristem())
axiom = TreeTypes.Internode() + TreeTypes.Meristem()
```

We add a function to grow the internodes over time:

```julia
function elongate!(tree)
    query = Query(TreeTypes.Internode)
    for x in apply(tree, query)
        x.length = x.length*(1.0 + data(tree).growth)
    end
end
```

And a query to extract the position and inclination of the leaves:

```julia
function leaf_info(tree)
    query = Query(TreeTypes.Leaf)
    heights = Float64[]
    angles = Float64[]
    for l in apply(tree, query)
        push!(heights, l.height)
        push!(angles, l.angle)
    end
    return heights, angles
end
```

We can now grow the tree:

```julia
function growth!(tree)
    elongate!(tree)
    rewrite!(tree)
end
```

And a simulation for `n` steps is achieved with a simple loop that returns the final
tree and the heights and angles of the leaves throughout the simulation:

```julia
function simulate(n)
    # Initialize the tree
    tree = Graph(axiom = axiom, rules = (meristem_rule, branch_rule),
             data = TreeTypes.treeparams())
    # Run simulation
    for i in 1:n
        growth!(tree)
    end
    Mesh(tree) # Generate the mesh to trigger feed!() methods
    heights, angles = leaf_info(tree)
    return tree, heights, angles
end
```

We can now run the simulation:

```julia
seed!(123456789);
tree, heights, angles = simulate(25);
```

We can check how the final tree looks like:

```julia
render(Mesh(tree))
```

And we can plot the distribtuion of leaf heights and angles:

```julia
length(heights)
density(heights, bandwidth = 1, trim = true)
density(angles, bandwidth = 5, trim = true)
```

We can see that the distribution of leaves over height is not uniform but rather there is
a higher density of leaves towards the middle of the tree. This is an emergent pattern of
the developmental rules and growth parameters defined in the model. Similarly, the angle
distribution is not uniform bur rather skewed towards more vertical leaves. This is a
result of the insertion angles of leaves and branches defined in the model.

Note that in this example we are calculating the center and inclination angle of the
leaf explicitly from the turtle's state. This is possible because the shape of the leaf
is relatively simple. A more general approach is to extract the mesh from the scene and
calculate the center and orientation of the leaf from the triangles. We will show how to
do this in the next section.

## Extracting triangles

In VPL, all geometry is represented by triangular meshes. A mesh may be created by an
user by calling any of the primitive constructors within VPL (e.g., `Rectangle!()`) or
by any alternative code that generates a mesh and added using the `Mesh!()` method. This
means that the turtle will internally store a single triangular mesh that combines all
the geometry generated so far. This will be passed on to the scene and (when relevant)
merged with other meshes.

One possible approach is to generate the mesh inside the `feed!()` method without adding
it to the turtle, extracting all the information needed and then adding the mesh to the
turtle. In order to implement this we just need to modify the `feed!()` method for the
leaves as follows:

```julia
# Create geometry + color for the leaves
function VirtualPlantLab.feed!(turtle::Turtle, l::TreeTypes.Leaf, vars)
    # Rotate turtle around the arm for insertion angle
    ra!(turtle, -vars.leaf_angle)
    # We generate the leaf without adding it to the turtle -> just remove the "!"
    # And don't include colors or materials
    e = Ellipse(turtle, length = l.length, width = l.width, move = false)
    # Compute the center of the leaf
    verts = vertices(e) # Extract all vertices (vector of vertices)
    zs    = getindex.(verts, 3) # Extract z-coordinate of each vertex
    l.height = mean(zs) # Average height of the leaf
    # Compute the inclination angle of the leaf (zenith of normal = inclination of plane)
    n = normals(e)[1] # All triangles will have the same normal so one suffices
    l.angle = acos(n[3])*180/π
    l.angle = l.angle > 90 ? 180.0 - l.angle : l.angle  # Correct for the angle being > 90
    # Add the leaf to the turtle (important to do transform = false, deepcopy = false)
    Mesh!(turtle, e, colors = RGB(0.2,0.6,0.2), transform = false, deepcopy = false)
    # Rotate turtle back to original direction
    ra!(turtle, vars.leaf_angle)
    return nothing
end
```

We can now run the simulation:

```julia
seed!(123456789);
tree, heights2, angles2 = simulate(25);
```

And confirm that we get the same tree:

```julia
render(Mesh(tree))
length(angles) == length(angles2)
```

The heights are the same:.

```julia
density(heights2, bandwidth = 1, trim = true, label="Triangles")
density!(heights, bandwidth = 1, trim = true, label = "Turtle")
```

The angles are also the same (makes sense since the normals of the triangles are the same
as the up vector of the turtle):

```julia
density(angles2, bandwidth = 5, trim = true, label="Triangles")
density!(angles, bandwidth = 5, trim = true, label = "Turtle")
```
