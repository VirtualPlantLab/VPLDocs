# How to setup a grid cloner

In many FSP models, users want to simulate a large field of plants, but it is not computationally
feasible to do so. Instead, a reduced number of representative plants in a plot are simulated.
However, this can introduce border effects when simulating plant-environment interactions (for
example when computing light interception). The goal of the grid cloner is to reduce this
border effect when computing light interception by cloning the entire 3D scene along the
different axes by a distance specified by the user (in each direction).

The grid cloner is implemented using *object instancing* from ray tracing. This approach will
affect the position of the ray as if it was intersecting a cloned scene adjacent to the
original one, thus still reusing the original mesh. For example, if the scene is replicated
along the x-axis at a distance of 1, the ray will be translated a distance of -1 along the
x-axis to check for intersections with that clone. Thus, no extra memory is required to
store the clones.

Conceptually, this grid cloner is similar to using *periodic boundaries* on the sides of the
bounding box of the scene. The main differences are that (i) the grid cloner only allows a
finite number of clones (periodic boundaries could be, in theory, infinite) and (ii) the
bounding boxes of clones may overlap. The latter feature accounts for the fact that the
root and shoot systems of plants may *overlap* in the field.

In the most common scenario, the user is simulating a field of plants with a regular spacing
between plants (e.g., defined by distance between rows and within rows). In this case, the
recommended way to create the grid cloner is as follows:

- The clones should be created at multiples of these distances.

- The rows should be aligned with the x- or y-axis.

- Soil and sensor tiles should not extend more than half the distance between or within rows along each axis.

In this canonical setup, the clones will overlap if the shoot or root systems of the border
plants extend beyond the midpoint between or within rows, but the soil/sensor tiles will not
overlap. The latter is important as otherwise calculations of light interception by such tiles
will be incorrect.

## Example

Load the dependencies

```julia
using VirtualPlantLab
import ColorTypes: RGB
import GLMakie
```

A plant will be represented by a simple cylinder located at different points in a grid. We
create the grid given the recommendations in the above. Using this template ensures that
the scene has the proper dimensions while still scaling with the number of plants and rows:

```julia
dx = 2.0
dy = 0.5
nrows = 10
nplants = 10
origins = [Vec(i,j,0) for i = dx/2:dx:(nrows - 0.5)dx, j = dy/2:dy:(nplants - 0.5)dy];
```

We create a simple plant placeholder defined by a stem and a single long leaf:

```julia
struct Plant <: Node end
function VirtualPlantLab.feed!(turtle::Turtle, plant::Plant, data)
    HollowCylinder!(turtle, move = true, color = RGB(0.63, 0.63, 0.63), length = 2.0,
                    width = 0.25, height = 0.25)
    rh!(turtle, rand()*360.0)
    ra!(turtle, rand()*90.0)
    Rectangle!(turtle, color = RGB(0.0, 1.0, 0.0), length = 3.0, width = 0.2)
    return nothing
end
axiom(origin) = T(origin) + Plant()
plants = [Graph(axiom = axiom(origin)) for origin in origins];
```

We will also add several soil tiles to the scene. Each tile will correspond to a single plant
and thus represent the spacing allocated to each plant given the planting pattern. We will
not use a graph for these tiles but rather create them *manually* using available primitives
and transformations (note how we shift the tile along the x axis to center it on the
plant!):

```julia
function create_tile(p, dx, dy)
    tile = Rectangle(length = dx, width = dy)
    rotatey!(tile, pi/2)
    VirtualPlantLab.translate!(tile, p .+ Vec(-dx/2, 0.0, 0.0))
    return tile
end
tiles = vec([create_tile(origin, dx, dy) for origin in origins]);
```

Now we can combine the plants and tiles into a single scene. We randomize the color of each
tile to help identify them in the visualization:

```julia
plant_scene = Scene(vec(plants));
soil_scene = Scene()
for tile in tiles
    add!(soil_scene, mesh = tile, color = RGB(rand(), rand(), rand()))
end
scene = Scene([plant_scene, soil_scene]);
render(scene)
```

We can also visualize the bounding boxes of a scene (and any clone). If we just want the
box for the original scene, we can create a grid with no clones. The build the acceleration
object (which includes the grid cloner) and add it to the 3D rendering:

```julia
rt_settings = RTSettings(nx = 0, ny = 0)
acc_one = accelerate(scene, settings = rt_settings);
render(scene)
render!(acc_one.grid)
```

We can see that bounding box extends to the tips of the leaves, as they grow beyond the soil
area allocated to the plant. If we now create multiple clones of this scene, we should
displace them by a distance of `10dx` along the x-axis and `10dy` along the y-axis. This
will ensure that the soil tiles of clones do not overlap but the plants will. In other words,
we emulate additional rows and plants within rows while respecting the same spacing between
them:

```julia
rt_settings = RTSettings(nx = 1, ny = 1, dx = 10dx, dy = 10dy)
acc = accelerate(scene, settings = rt_settings);
```

We can now add all the bounding boxes of the clones to the scene:

```julia
render(scene)
render!(acc.grid)
```

We can see that the bounding boxes of the clones overlap, as expected. Currently there is no
way in VPL to visualize the actual clones (since that additional geometry is never actually
generated, see details about *instancing* above). We can do this manually by manually changing
the meshes of the scene using the method `VirtualPlantLab.translate!`. We add the bounding
box of the original scene too:

```julia
scenes = Scene[]
for i in -10:10
    for j in -10:10
        new_scene = deepcopy(scene)
        VirtualPlantLab.translate!(new_scene.mesh, Vec(i*10dx, j*10dy, 0.0))
        push!(scenes, new_scene)
    end
end
render(Scene(scenes), axes = false)
render!(acc_one.grid, alpha = 0.8)
```

Because of the random color scheme, we can visually check that the soil tiles do not
overlap and that the distance within and between rows is respected across clones. Effectively,
this is a visualization of what the ray tracer "sees" in the simulations. Effectively, each
plant in the original scene is cloned multiple times and the absorbed power from all these
clones is aggregated. However, the light sources are not being duplicated, those are still
defined by the original scene (which is located in the center of the grid).
