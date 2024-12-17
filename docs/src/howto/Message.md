# Messages in scene

In VPL it is possible to generate different scenes from the same graph or collection of
graphs. This is achieved by passing a message to the `feed!` methods when creating the
`Scene` object. A message is any object (of any type) assigned to the keyword argument
`message` inside any `Scene()` method. Within a `feed!` method, the message can be from the
turtle object (first argument of the method call) as `turtle.message` (assuming the object
is named `turtle`). Examples of cases when messages can be used include:

* Differentiating between geometry needed for visualization and for ray tracing (e.g. we may want to include roots in the visualization but not in the ray tracing).

* Changing the color associated to some geometry (e.g. we may want to color the leaves of a plant based on the amount of light they receive).

* Changing the geometry based on the message (e.g. we may want a higher level of realism for visualization that for ray tracing to reduce computational costs).

Let's illustrate how to use messages with a simple example. We will modify the Tree tutorial
to allow for visualizing. Below is all the code for the tree model excluding the `feed!`
methods

```julia
using VirtualPlantLab
using ColorTypes
import GLMakie

# Data types
module TreeTypes
    import VirtualPlantLab
    # Meristem
    struct Meristem <: VirtualPlantLab.Node end
    # Bud
    struct Bud <: VirtualPlantLab.Node end
    # Node
    struct Node <: VirtualPlantLab.Node end
    # BudNode
    struct BudNode <: VirtualPlantLab.Node end
    # Internode (needs to be mutable to allow for changes over time)
    Base.@kwdef mutable struct Internode <: VirtualPlantLab.Node
        length::Float64 = 0.10 ## Internodes start at 10 cm
    end
    # Leaf
    Base.@kwdef struct Leaf <: VirtualPlantLab.Node
        length::Float64 = 0.30 ## Leaves are 20 cm long
        width::Float64  = 0.2 ## Leaves are 10 cm wide
    end
    # Graph-level variables
    Base.@kwdef struct treeparams
        growth::Float64 = 0.1
        budbreak::Float64 = 0.25
        phyllotaxis::Float64 = 140.0
        leaf_angle::Float64 = 30.0
        branch_angle::Float64 = 45.0
    end
end

# Rules
meristem_rule = Rule(TreeTypes.Meristem, rhs = mer -> TreeTypes.Node() +
                                              (TreeTypes.Bud(), TreeTypes.Leaf()) +
                                         TreeTypes.Internode() + TreeTypes.Meristem())

function prob_break(bud)
    # We move to parent node in the branch where the bud was created
    node =  parent(bud)
    # We count the number of internodes between node and the first Meristem
    # moving down the graph
    check, steps = has_descendant(node, condition = n -> data(n) isa TreeTypes.Meristem)
    steps = Int(ceil(steps/2)) ## Because it will count both the nodes and the internodes
    # Compute probability of bud break and determine whether it happens
    if check
        prob =  min(1.0, steps*graph_data(bud).budbreak)
        return rand() < prob
    # If there is no meristem, an error happened since the model does not allow
    # for this
    else
        error("No meristem found in branch")
    end
end
branch_rule = Rule(TreeTypes.Bud,
            lhs = prob_break,
            rhs = bud -> TreeTypes.BudNode() + TreeTypes.Internode() + TreeTypes.Meristem())

# Graph
axiom = TreeTypes.Internode() + TreeTypes.Meristem()
tree = Graph(axiom = axiom, rules = (meristem_rule, branch_rule), data = TreeTypes.treeparams())

# Growth functions
getInternode = Query(TreeTypes.Internode)
function elongate!(tree, query)
    for x in apply(tree, query)
        x.length = x.length*(1.0 + data(tree).growth)
    end
end
function growth!(tree, query)
    elongate!(tree, query)
    rewrite!(tree)
end

# Simulation
function simulate(tree, query, nsteps)
    new_tree = deepcopy(tree)
    for i in 1:nsteps
        growth!(new_tree, query)
    end
    return new_tree
end
```

There are three types of nodes that require geometry: `Leaf`, `Internode`, and `BudNode`,
though the latter only adds the insertion angle for the branches. In the example below we
will use the message to select whether to visualize the leaves or not. This would be useful
if we want to visualize the branching structure of a tree with a dense canopy (to make it
more meaningful we make the leaves bigger than in the original example). Note how, even
when we don't generate internodes we still need to modify the state of the turtle to ensure
the correct positioning of the leaves.

```julia
# Insertion angle for the bud nodes
function VirtualPlantLab.feed!(turtle::Turtle, b::TreeTypes.BudNode, vars)
    # Rotate turtle around the arm for insertion angle
    ra!(turtle, -vars.branch_angle)
end

# Create geometry + color for the internodes
function VirtualPlantLab.feed!(turtle::Turtle, i::TreeTypes.Internode, vars)
    # Rotate turtle around the head to implement elliptical phyllotaxis
    rh!(turtle, vars.phyllotaxis)
    # Generate the internode or move the turtle forward
    if turtle.message == "leaves"
        f!(turtle, i.length)
    else
        HollowCylinder!(turtle, length = i.length, height = i.length/15, width = i.length/15,
                    move = true, colors = RGB(0.5,0.4,0.0))
    end
    return nothing
end

# Create geometry + color for the leaves
function VirtualPlantLab.feed!(turtle::Turtle, l::TreeTypes.Leaf, vars)
    # Bypass geometry if only internodes are being rendered
    turtle.message == "internodes" && return nothing
    # Rotate turtle around the arm for insertion angle
    ra!(turtle, -vars.leaf_angle)
    # Generate the leaf
    Ellipse!(turtle, length = l.length, width = l.width, move = false,
             colors = RGB(0.2,0.6,0.2))
    # Rotate turtle back to original direction
    ra!(turtle, vars.leaf_angle)
    return nothing
end
```

We can now generate a simulation:

```julia
newtree = simulate(tree, getInternode, 15)
```

For a visualization of both leaves and internodes we can actually leave the message empty
given how the code above is structured:

```julia
mesh = Mesh(newtree);
render(mesh, axes = false)
```

For only leaves:

````julia
mesh = Mesh(newtree, message = "leaves");
render(mesh, axes = false)
````

And for only internodes:

````julia
mesh = Mesh(newtree, message = "internodes");
render(mesh, axes = false)
````
