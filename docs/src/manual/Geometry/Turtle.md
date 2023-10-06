# [Turtle geometry and scenes](@id manual_turtle)

Alejandro Morales

Centre for Crop Systems Analysis - Wageningen University


<!-- Explain the PlantGeomTurtle package -->

## Meshes

The geometry in VPL consist of 3D triangular meshes. These meshes are used for
3D visualization and for ray tracing, buy may also be exported to external formats
or used in other Julia packages. Most of the time, the geometry is generated
from graphs using the concept of turtle geometry. In addition to generating the
meshes, it will also be necessary to associated colors (for rendering) and
material objects (for ray tracing) for each triangle in the mesh. All these
components are then stored in a `Scene` object.

Meshes are collections of vertices, normal vectors and faces (which specify
combinations of vertices that form triangles). They are implemented in the object
`Mesh`. All vectors and points are represented by the type `Vec`. Any vector may
be constructed by calling `Vec(x, y, z)` with the coordinates of the vector.

Meshes can be imported from external formats using the [`PlantGeomPrimitives.load_mesh()`](@ref) function and
exported using the [`PlantGeomPrimitives.save_mesh()`](@ref)
functions. The file formats supported include STL, OBJ and PLY (see documentation
on functions for details).

Meshes are not meant to be modified directly by the user (unless adhoc geometry
is needed). Instead, a series of functions are provided to generate meshes associated
to different geometries. These functions are called *primitive constructors* and
can be combined to generate more complex geometries. The primitive constructors
maybe used to generate geometry procedurally with a turtle (see below), or to
create the mesh directly (e.g., when adding geometry to an existing scene).


## Turtle geometry

The idea behind turtle geometry is to generate geometry procedurally by imagining
a turtle that moves through the scene and is fed triangular meshes. This allows
to generate any geometry by defining a sequence of instructions that the turtle
will execute. These instructions are defined locally (e.g., turn right, move
forward, etc.) and update the turtle position and orientation, such that a global
geometry is generated after the instructions are executed.

The internal state of the turtle is defined by its position and three axis of
rotation:

 - Position (`pos`): The location of the turtle in the scene.
 - Heading (`head`): The direction in which the turtle is heading. Moving forward
would mean moving along this direction. A rotation around the `head` vector is
called a *roll* (imagine a turtle spinning on its head).
 - Arm (`arm`): A direction perpendicular to `head` but on the same plane. A
rotation around the `arm` vector is called a *pitch* (imagine a turtle turning
up or down).
 - Up (`up`): A direction perpendicular to the plane of the turtle. A rotation
around the `up` vector is called a *yaw* (imagine a turtle turning left or right).

To generate geometry, that matches the morphology of a plant, the turtle in
VPL is fed a graph. This means that the first instructions to the turtle will be
given by the first node in the graph. The turtle will then traverse the entire
graph, resetting its state at each branching point in the graph. The instructions
to the turtle are given by methods of the `feed!()` function, defined for all the
possible nodes in graph.

Two types of instructions are available to the turtle: movement operators and
primitive constructors. The former are used to change the internal state of the
turtle without adding geometry to the scene, while the latter generate a 3D mesh
associated to a particular geometry (a special primitive constructor `Mesh!`
accepts any mesh generated by the user). The different movement operators are
given below, while the primitive constructors are given [here](@ref manual_primitives).

In addition, the turtle will contain a `message` field that can be assigned any
user-defined value. This is useful to pass information to `feed!()` methods
described below (e.g., to control the code executed by those methods). All the
methods that create an internal turtle (e.g., `Scene` or `render`) will accept
an optional `message` argument that will be passed on to the turtle.

## Movement operators

Movement operators as provided as functions that manipulate the state of the
turtle in-place (e.g. `ra!`), as well as nodes that can be used inside a `Graph`
object (e.g., `RA`). The functional version will be in lowercase, while the node
version will be in uppercase. The functional version can be used inside any
`feed!()` method, which reduces the number of nodes that need to be inserted into
a graph.

Below are all the movement operators available in VPL (in their node form):

  - [`PlantGeomTurtle.T`](@ref): Move the turtle to a new absolute position.
  - [`PlantGeomTurtle.RA`](@ref): Rotate the turtle around the`arm` axis.
  - [`PlantGeomTurtle.RH`](@ref): Rotate the turtle around the `head` axis.
  - [`PlantGeomTurtle.RU`](@ref): Rotate the turtle around the `up` axis.
  - [`PlantGeomTurtle.OR`](@ref): Orient the turtle in a new direction by explicitly changing
the `head`, `arm` and `up` vectors.
  - [`PlantGeomTurtle.F`](@ref): Move the turtle forward.
  - [`PlantGeomTurtle.SET`](@ref): Completely change the state of the turtle by setting the
`pos`, `head`, `arm` and `up` vectors.
  - [`PlantGeomTurtle.RV`](@ref): A special rotation that emulates gravitropism (it rotates
the turtle towards the Z axis of the scene).


## Scenes

A `Scene` object contains three elements that are connected:

 - A triangular mesh (a `Mesh` object) that contains all the geometry of the
scene.
 - The colors associated to each triangle in the mesh (objects that inherit from
`Colorant` from the ColorTypes.jl package). This is needed for 3D rendering.
  - The `Material` objects that defined the optical properties of each triangle.
This is needed for ray tracing of radiation.

Only the first element is required to create a scene. The other two are optional
and are only necessary if you want to render the scene or perform ray tracing on
the scene.

### Creating a scene

The simplest way to create a scene is to use the `Scene` constructor on a `Graph`
object or a vector of `Graph` objects. This will create internally a `Turtle`
which then generates the geometry, colors and materials of the scene via the
`feed!()` methods defined by the user. VPL will take care of ensuring that
triangles are connected to their corresponding colors and material objects.

A scene may also be created internally by `render()` when applied to a `Graph`
object or a vector of `Graph` objects. However, this scene cannot be retrieved
so it is not possible to modify it or reuse it for ray tracing. The ray tracer
will not create a scene internally, so for that purpose the user will need to
create the scene explicitly.

It is possible to add elements to an existing scene using the `add!()` method
which allows to add a mesh to the scene (and optionally the corresponding colors
and/or materials).

Multiple scenes can also be merged into a single one by calling `Scene()` on a
vector of `Scene` objects. This allows for parallel construction of scenes which
are then merged together.

### The `feed!()` method

In order to use the turtle to generate a scene from a graph, the user will need
to define a `feed!()` method for each type of node stored in the graph (at least
the ones that require geometry). This method will be called by the turtle when
it encounters a node of that type. When no method is present, the turtle will
simply move to the next node in the graph.

The `feed!()` method takes three arguments: the `Turtle`, the node and the graph-
level variables (of the graph the node belongs to). The latter does not have to
be used, but it may be useful if information at the plant level is required to
generate geometry, colors or material objects (most often the information is
stored inside the node itself). It is important that the second
argument (the node) is annotated by its type and that the `PlantGeomTurtle` prefix is used
to ensure that a method is created. For example, for a node of type `Internode`
the function should be defined as:

```julia
function PlantGeomTurtle.feed!(t::Turtle, n::Internode, vars)
    <code here>
end
```

Inside the `feed!()` method, the user can apply any of the movement operators
described in the previous section as well as the turtle-specific primitive
constructors (see section on [Primitives](@ref manual_primitives)). All these changes
will be applied to the turtle's internal state. The `feed!()` method should not
return anything.

It is also possible to execute different code inside the `feed!()` method based
on the `message` stored in the turtle. This allows for example to generate
different geometries for visualizations and ray tracing, or to use different
colors for visualization. Since the `message` can be any object created by the
user, it may also be used to pass information to the `feed!()` method, though
most often the relevant information is stored in the node or graph.