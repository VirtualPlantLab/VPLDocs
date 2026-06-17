# [Ecophys](@id ecophys)

Alejandro Morales

Centre for Crop Systems Analysis - Wageningen University

This package contains modules describing different ecophysiological functions of
plants, including processes such as photosynthesis, respiration, transpiration
or phenology. They may be used as standalone or as a component of a plant growth
model.

## Installation

To install Ecophys.jl, you can use the following command:

```julia
] add Ecophys
```

Or, if you prefer the development version:

```julia
import Pkg
Pkg.add(url = "https://github.com/VirtualPlantLab/Ecophys.jl.git", rev = "master")
```

## Photosynthesis

The module Photosynthesis contains functions to calculate leaf CO2 assimilation
and stomatal conductance for C3 and C4 species, based on the work by [Yin & Struik (2009, NJAS)](https://www.tandfonline.com/doi/full/10.1016/j.njas.2009.07.001).
To create a model, use the corresponding function (`C3()` or `C4()`) and pass the
parameters as keyword arguments (they all have default values that correspond to Tables 2 the original publication):

```julia
using Ecophys
c3 = C3(Vcmax25 = 140.0)
c4 = C4(Vcmax25 = 140.0)
```
To compute CO2 assimilation and stomatal conductance, use the `photosynthesis()` function,
passing the photosynthesis model and the environmental conditions as inputs (with
defaults):

```julia
A_c3, gs_c3  = photosynthesis(c3, PAR = 100.0)
A_c4, gs_c4  = photosynthesis(c4, PAR = 100.0)
```

It is also possible to work with physical units using the Unitful.jl package. In
such case, the functions `C3Q()` and `C4Q` should be used to create the model but
now the parameters are stored as `Quantity` objects:

```julia
using Unitful.DefaultSymbols # import symbols for units
c3Q = C3Q(Vcmax25 = 140.0μmol/m^2/s)
c4Q = C4Q(Vcmax25 = 140.0μmol/m^2/s)
```

And the environmental conditions should be passed as `Quantity` objects (defaults
are updated accordingly, see Unitful.jl documentation for details on how to
create `Quantity` objects):

```julia
A_c3, gs_c3  = photosynthesis(c3Q, PAR = 100.0μmol/m^2/s)
A_c4, gs_c4  = photosynthesis(c4Q, PAR = 100.0μmol/m^2/s)
```

## Leaf Energy Balance

Ecophys may also compute the leaf energy balance to couple photosynthesis,
transpiration and leaf temperature. In addition to the models of photosynthesis
and stomatal conductance mentioned in the above, additional models of boundary
layer conductance and leaf optical properties are required.

Currently, only a simple model of optical properties is avaiable that defines
the leaf absorptance in PAR and NIR and its emmisivity in the thermal domain.
This model is created using the `SimpleOptical()` function (defaults are provided):

```julia
using Ecophys
opt = SimpleOptical(αPAR = 0.80)
```

Two models to compute the boundary layer conductance are available. They differ
in the amount of information used regarding the geometry of the leaf. A simple
model only accounts for the leaf characteristic length and is the most common
approach (as before, a version that supports `Quantity` objects is also available):

```julia
gb = simplegb(d = 0.1)
gbQ = simplegbQ(d = 0.1m)
```

The second model is more complex as it takes into account the aspect ratio (length/width) of
the leaf as well as its inclination angle. It will also distinguish between the
boundary layer conductance of the front and back side of the leaf. This model
relies on unpublished equations fitted to the data reviewed by
[Schuepp (1993, New Phyto)](https://nph.onlinelibrary.wiley.com/doi/10.1111/j.1469-8137.1993.tb03898.x):

```julia
gbang = gbAngle(d = 0.1, ang = π/4, ar = 0.1)
gbangQ = gbAngleQ(d = 0.1m, ang = π/4, ar = 0.1)
```

The leaf energy balance is then computed using `solve_energy_balance()` which
will compute the leaf temperature that closes the energy balance as well as the
corresponding CO2 assimilationa and transpiration:

```julia
Tleaf, A, Tr = solve_energy_balance(c3; gb = gb, opt = opt, PAR = 100.0, ws = 5.0)
TleafangQ, AangQ, TrangQ = solve_energy_balance(c3Q; gb = gbangQ, opt = opt, PAR = 100.0μmol/m^2/s, ws = 5.0m/s)
```



# Photosynthesis

```@meta
CurrentModule = Ecophys.Photosynthesis
```

## Public API

```@autodocs
Modules = [Photosynthesis]
Public = true
Private = false
```

## Private

Private functions, types or constants from `Photosynthesis`. These are not exported, so you need to prefix the function name with `PlantGeomPrimitives.` to access them. Also bear in mind that these are not part of the public API, so they may change without notice.

```@autodocs
Modules = [Photosynthesis]
Public = false
Private = true
```


# PlantBioPhysics

The documentation for PlantBioPhysics.jl is hosted in its own [website](https://vezy.github.io/PlantBiophysics.jl/stable/).


# PlantSimEngine

The documentation for PlantSimEngine.jl is hosted in its own [website](https://virtualplantlab.github.io/PlantSimEngine.jl/stable/). Public and private API is documented below:

```@meta
CurrentModule = PlantSimEngine
```
## API documentation

```@autodocs
Modules = [PlantSimEngine]
Private = false
```

## Un-exported

Private functions, types or constants from `PlantSimEngine`. These are not exported, so you need to use `PlantSimEngine.` to access them (*e.g.* `PlantSimEngine.DataFormat`).

```@autodocs
Modules = [PlantSimEngine]
Public = false
Private = true
```



# Sky models

```@meta
CurrentModule = SkyDomes
```

## Index

```@index
Modules = [SkyDomes]
Public = true
Private = true
```

## Public API

```@autodocs
Modules = [SkyDomes]
Public = true
Private = false
```

## Private

Private functions, types or constants from `SkyDomes`. These are not exported, so you need to prefix the function name with `PlantGeomPrimitives.` to access them. Also bear in mind that these are not part of the public API, so they may change without notice.

```@autodocs
Modules = [SkyDomes]
Public = false
Private = true
```



# [SkyDomes](@id sky)

Alejandro Morales

Centre for Crop Systems Analysis - Wageningen University

The package SkyDomes provides a function to calculate the solar radiation on a
horizontal surface (for clear skies) as a function of latitude, day of year and
time of the day and for different wavebands. In addition, it can generate light
sources as required by the [Virtual Plant Lab](https://github.com/VirtualPlantLab/VirtualPlantLab.jl) to
simulate the light distribution in a 3D scene.

## Installation

To install SkyDomes.jl, you can use the following command:

```julia
] add SkyDomes
```

Or, if you prefer the development version:

```julia
import Pkg
Pkg.add(url = "https://github.com/VirtualPlantLab/SkyDomes.jl.git", rev = "master")
```

## Usage


### Solar radiation

Use the `clear_sky` function to calculate the solar radiation on a horizontal
plane as a function of day of year, latitude (in radians) and the relative solar
time of the day (`f = 0` is sunrise, `f = 1` is sunset). The function returns
the total solar radiation in W/m² as well as direct and diffuse components. For
example:

```julia
using Sky
lat = 52.0*π/180.0 # latitude in radians
DOY = 182
f = 0.5 # solar noon
Ig, Idir, Idif = clear_sky(lat = lat, DOY = DOY, f = f) # W/m2
```

The values `Ig`, `Idir` and `Idif` are the total, direct and diffuse solar
radiation in W/m². The function `waveband_conversion` can be used to convert
these values to specfic wavebands (UV, PAR, NIR, blue, green or red) as well
as converting from W/m² to umol/m²/s, assuming particular spectra for
direct and diffuse solar radiation. For example:

```julia
f_PAR_dir = waveband_conversion(Itype = :direct, waveband = :PAR, mode = :flux)
Idir_PAR = f_PAR_dir*Idir # PAR in umol/m²/s
f_PAR_dif = waveband_conversion(Itype = :diffuse, waveband = :PAR, mode = :flux)
Idif_PAR = f_PAR_dif*Idif # PAR in umol/m²/s
```

### Light sources for ray tracing

Once the direct and diffuse solar radiation in the relevant wavebands and units
have been calculated, the function `sky` can be used to generate the light
sources required by VPL to simulate the light distribution in a 3D scene. For
example, a simple horizontal tile (representing soil) in VPL may be created as
follows:

```julia
using VPL
r = Rectangle(length = 2.0, width = 1.0)
rotatey!(r, -π/2) # To put it in the XY plane
translate!(r, Vec(0.0, 0.5, 0.0))
render(r)
```

A 3D scene requires adding optical properties (e.g., a black material property)
and linking these to the mesh (for complicated scenes see [VPL documentation](http://virtualplantlab.com/)
for examples):

```julia
materials = [Black()]
ids = [1,1]
scene = RTScene(mesh = r, ids = ids, materials = materials)
```

If we want to compute the amount of solar radiation absorbed by this tile, we
need to create a series of light sources. The function `sky` can be used for
that purpose:

```julia
sources = sky(scene,
             Idir = Idir_PAR, # Direct solar radiation from above
             nrays_dir = 1_000_000, # Number of rays for direct solar radiation
             Idif = Idif_PAR, # Diffuse solar radiation from above
             nrays_dif = 10_000_000, # Total number of rays for diffuse solar radiation
             sky_model = StandardSky, # Angular distribution of solar radiation
             dome_method = equal_solid_angles, # Discretization of the sky dome
             ntheta = 9, # Number of discretization steps in the zenith angle
             nphi = 12) # Number of discretization steps in the azimuth angle
```

The function takes the scene as input to ensure that light sources scale with
the scene. Direct solar radiation is represented by a single directiona light
source that will emmit a number of rays given by `nrays_dir`. Diffuse solar
radiation is represented by a hemispherical dome of directional light sources
that will emmit a total of `nrays_dif` rays. The angular distribution of the
diffuse solar radiation and the discretization of the sky dome can be modified
via `dome_method, sky_model`, `ntheta` and `nphi`. See API documentation and
[VPL documentation](http://virtualplantlab.com/) for details.

Once the light sources are created, a ray tracing object can be generated
combining all the elements above:

```julia
settings = RTSettings(parallel = true)
rtobj = RayTracer(scene, sources, settings = settings);
```

And the ray tracing can be performed by calling the `trace!` function:

```julia
trace!(rtobj);
```

As expected, the amount of solar radiation absorbed by the tile equals the
total in the scene (`Ig`):

```julia
materials[1].power[1]/area(r) ≈ Idir_PAR + Idif_PAR
```

See [VPL documentation](http://virtualplantlab.com/) for more details and
tutorials on ray tracing simulations

## Roadmap for future dfevelopment

The package is still under development. The following features are planned:

- Calculate fraction of direct and diffuse radiation from measurements of actual
solar radiation.

- Calculate the solar radiation on a tilted surface.

- Allow for a different orientation of the 3D scene from VPL.

- More advanced algorithms for solar radiation and spectrum (e.g., SOLPOS, Bird).

See Issues for additional features to be implemented.



# Scenes and 3D meshes

```@meta
CurrentModule = PlantGeomPrimitives
```

## Public API

```@autodocs
Modules = [PlantGeomPrimitives]
Public = true
Private = false
```

## Private

Private functions, types or constants from `PlantGeomPrimitives`. These are not exported, so you need to prefix the function name with `PlantGeomPrimitives.` to access them. Also bear in mind that these are not part of the public API, so they may change without notice.

```@autodocs
Modules = [PlantGeomPrimitives]
Public = false
Private = true
```


# Graphs

```@meta
CurrentModule = PlantGraphs
```

## Public API

Includes functions defined by PlantGraphs as well as methods for functions defined by other
packages.

```@autodocs
Modules = [PlantGraphs]
Public = true
Private = false
```

## Private

Private functions, types or constants from `PlantGraphs`. These are not exported, so you need to prefix the function name with `PlantGeomPrimitives.` to access them. Also bear in mind that these are not part of the public API, so they may change without notice.

```@autodocs
Modules = [PlantGraphs]
Public = false
Private = true
```


# Raytracer

```@meta
CurrentModule = PlantRayTracer
```

## Public API

```@autodocs
Modules = [PlantRayTracer]
Public = true
Private = false
```

## Private

Private functions, types or constants from `PlantRayTracer`. These are not exported, so you need to prefix the function name with `PlantGeomPrimitives.` to access them. Also bear in mind that these are not part of the public API, so they may change without notice.

```@autodocs
Modules = [PlantRayTracer]
Public = false
Private = true
```



# Turtle Geometry

```@meta
CurrentModule = PlantGeomTurtle
```

## Public API

```@autodocs
Modules = [PlantGeomTurtle]
Public = true
Private = false
```

## Private

Private functions, types or constants from `PlantGeomTurtle`. These are not exported, so you need to prefix the function name with `PlantGeomPrimitives.` to access them. Also bear in mind that these are not part of the public API, so they may change without notice.

```@autodocs
Modules = [PlantGeomTurtle]
Public = false
Private = true
```


# 3D visualization

```@meta
CurrentModule = PlantViz
```

## Public API

```@autodocs
Modules = [PlantViz]
Public = true
Private = false
```

## Private

Private functions, types or constants from `PlantViz`. These are not exported, so you need to prefix the function name with `PlantGeomPrimitives.` to access them. Also bear in mind that these are not part of the public API, so they may change without notice.

```@autodocs
Modules = [PlantViz]
Public = false
Private = true
```


#  [Organization of VPL](@id organization)

In terms of implementation, VPL consists of a GitHub organization ([VirtualPlantLab](https://github.com/VirtualPlantLab/VirtualPlantLab.jl))
that contains 9 registered Julia packages. The packages are organized in two groups:

- The VPL core: These are the basic packages that provide the functionality to build FSP models. The user is normally not intended to use these packages directly but rather through the interface offered by [VirtualPlantLab.jl](https://github.com/VirtualPlantLab/VirtualPlantLab.jl). Developers who want to access the source code (and potentially modify it) should first identify the package that contains the functionality they are interested in.

- The *VPLverse*: These are packages that are built on top of the VPL core or standalone packages that provide additional functionality to build FSP models. The user needs to install these packages separately and import them if they wish to use them.

## The VPL core

The core of VPL consists of five packages that provide the basic functionality plus the
interface meta-package [VirtualPlantLab.jl](https://github.com/VirtualPlantLab/VirtualPlantLab.jl)
(which simply collects and exports the public API of the core packages). The packages that form the core of VPL are:

- [PlantGraphs.jl](https://github.com/VirtualPlantLab/PlantGraphs.jl): A dynamic graph rewriting system where user-defined objects are stored in each node and these nodes can be queried and replaced by sub-graphs through dynamic production rules. Everything related to graph rewriting is implemented in this package (e.g., the `Node` abstract type, as well as `Graph`, `Query` and `Rule`).

- [PlantGeomPrimitives.jl](https://github.com/VirtualPlantLab/PlantGeomPrimitives.jl): A collection of 3D primitives implemented as triangular meshes stored in a scene for the purpose of visualization and ray tracing. This package defines the `Scene` data type that is used to store 3D meshes.

- [PlantGeomTurtle.jl](https://github.com/VirtualPlantLab/PlantGeomTurtle.jl): An implementation of turtle algorithms that can generate 3D meshes from graphs representing the topology and structure of individual plants. This package defines the `feed!` function that users work with when generating 3D meshes from their own data types.

- [PlantRayTracer.jl](https://github.com/VirtualPlantLab/PlantRayTracer.jl): A physics-based forward Monte Carlo ray tracer for the purpose of computing light interception by individual plants under field or controlled growth conditions. The ray tracer is multithreaded and uses bounding volume hierarchies. Everything related to ray tracing (light sources, materials, etc.) is implemented in this package, except the specific functions to emulate sky conditions (see SkyDomes.jl below).

- [PlantViz.jl](https://github.com/VirtualPlantLab/PlantViz.jl): 3D rendering of scenes based on the different backends of [Makie.jl](https://docs.makie.org/stable/). This package defines the `render` function.

## The VPLverse

VPL contains all the basic functionality to build FSP models but, as
indicated earlier, the emphasis is on minimal, simple and transparent interfaces.
In order to facilitate the construction of non-trivial FSP models, an ecosystem of
packages built around VPL provide additional support to the modeler by offering
reusable modules that can be reused in new models.

The packages currently planned for VPLverse are:

* [Ecophys.jl](https://github.com/VirtualPlantLab/Ecophys.jl) - Algorithms and data structures to simulate ecophysiological processes including photosynthesis, transpiration, leaf energy balance, phenology or respiration.

* [SkyDomes.jl](https://github.com/VirtualPlantLab/SkyDomes.jl) - Algorithms to simulate different sky conditions in terms of the intensity of solar radiation and its spatial and angular distribution.

* [PlantSimEngine.jl](https://github.com/VirtualPlantLab/PlantSimEngine.jl) - A package for the simulation and modeling of plants, soil and atmosphere. It is designed to help researchers and practitioners prototype, implement, test plant/crop models at any scale, without the hassle of computer science technicality behind model coupling, running on several time-steps or objects.

* [PlantBioPhysics.jl](https://vezy.github.io/PlantBiophysics.jl/stable/) - A package to deal with biophysical processes of plants such as photosynthesis, conductances for heat, water vapor and CO₂, latent, sensible energy fluxes, net radiation and temperature.


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


# The Virtual Plant Laboratory

Alejandro Morales

Centre for Crop Systems Analysis - Wageningen University


## Introduction

The Virtual Plant Laboratory (VPL) is a collection of Julia packages that aid in the
construction, simulation and visualization of functional-structural plant models (FSPM).
Users are meant to make use of the interface package (VirtualPlantLab.jl) which provides the
API to the different packages in VPL. Additional packages complement the functionality of VPL
forming the *VPLverse* (see below for details).

VPL is not a standalone solution to all the computational problems relevant to FSPM,
but rather it focuses on those algorithms and data structures that are specific to
FSPM and for which there are no good solutions in the Julia package ecosystem.
Furthermore, VPL is 100% written in Julia and therefore VPL will work in any
platform and with any code editor where Julia works. Finally, VPL does not offer
a domain specific language for FSPM but rather it allows building FSP models by
creating user-defined data [types](https://docs.julialang.org/en/v1/manual/types/)
and [methods](https://docs.julialang.org/en/v1/manual/methods/).

There is no standard definition of what an FSPM is (though these models will
always involve some combination of plant structure and function) so VPL may
not be useful with every possible FSPM. Instead, VPL focuses on
models that represent individual plants as graphs of elements (usually organs)
that interact with each other and with the environment. In a typical VPL model,
each plant is represented by its own graph which can change dynamically through
the iterative application of graph rewriting rules. Based on this goal, what VPL
offers are data structures and algorithms that allow modelling the dynamic evolution
of graphs that represent plants as collections of organs or other morphological elements and
modelling the interaction between plants and their environment by generating 3D structures
and simulating capture of different resources (e.g. light).

In terms of design, VPL gives priority to performance and simple interfaces as
opposed to complex layers of abstraction. This implies that models in VPL may
be more verbose and procedural (as opposed to descriptive) than in other FSPM
software, but that may also make them more transparent and easier to follow.

## Installation

VPL requires using Julia version 1.9 or higher. The installation of core of VPL is as
easy as running the following code:

```julia
] add VirtualPlantLab
```

This will install all the packages that form the core of VPL. Additional packages that are meant to work with VPL (or
as standalone packages) are available as part of the *VPLverse* (see section on
[Organization](@ref organization)). These are not necessary to build an FSP models but in
many cases they will be useful to complement the functionality of VPL.

## Documentation

Documentation for VPL is provided in this website in four formats:

1. User manual
2. Tutorials
3. API
4. VPLverse
5. Technical notes for developers

New users are expected to start with the tutorials and consult the user manual
to understand better the different concepts used in VPL and get an overview of
the different options available. The API documentation describes each individual
function and data type, with an emphasis on inputs and outputs and (in addition
to this website) it can be accessed from within Julia with `?` (see the section
[Accessing Documentation](https://docs.julialang.org/en/v1/manual/documentation/#Accessing-Documentation-1)
in the Julia manual).

The technical notes are useful for people who want to understand the internal details of VPL
and how different algorithms are implemented (i.e. the technical notes should be seen as a
supplement to the source code of VPL).


# [Geometry primitives](@id manual_primitives)

Alejandro Morales

Centre for Crop Systems Analysis - Wageningen University


```julia
using VIrtualPlantLab
import ColorTypes: RGBA # for the color of each mesh
import GLMakie # For 3D rendering (native OpenGL backend)
```

VPL offers several functions to created 3D meshes that correspond to common
geometric shapes (i.e., primitives). They are meant to represent simple geometry
elements or to build more complex geometries through the use of turtle-based
procedural geometry. For that reason, there are two versions of each primitive
constructor: one that constructs the mesh directly (with a standard location
and orientation) and one that *feeds* the mesh to a turtle. The former is meant
to be used when manually adding geometries to am existing scene (e.g., soil,
structural elements) whereas the latter is mean to be used within the `feed`
methods associated to nodes in a graph. Additional functions are able to
translate and rotate these meshes to the desired location and orientation (see
API of the Geometry module for details).

Below, the functions for direct construction of the meshes are listed. The
turtle-based constructor have the same argument plus the turtle arugment itself
as well as optional arguments for color and optical materias (see API of the
Geometry module for more details).

Each primitive is visualized using the `render` function form VPL. These 3D
visualizations keep the axes to help understand what the standard location
and orientation are (use `axes = false` to turn off). They also set `normals = true`
and `wireframe = true` to highlight how the mesh is partitioned into triangles
and the normal vectors of each triangle (this is important for the ray tracer and
when exporting meshes out of VPL). All meshes are rendered in green assuming 50%
transparency (`color = RGBA(0,1,0,0.5)`). Note that one must use `transparency = true`
to ensure that the transparency is enabled when rendering the mesh.

## Triangle
```julia
p = Triangle(length = 1.0, width = 1.0)
render(p, wireframe = true, normals = true, color = RGBA(0,1,0,0.5), transparency = true)
```

## Rectangle
```julia
p = Rectangle(length = 1.0, width = 1.0)
render(p, wireframe = true, normals = true, color = RGBA(0,1,0,0.5), transparency = true)
```

## Trapezoid
```julia
p = Trapezoid(length = 1.0, width = 1.0, ratio = 0.5)
render(p, wireframe = true, normals = true, color = RGBA(0,1,0,0.5), transparency = true)
```

## Ellipse
```julia
p = Ellipse(length = 1.0, width = 1.0, n = 30)
render(p, wireframe = true, normals = true, color = RGBA(0,1,0,0.5), transparency = true)
```

## Axis-aligned bounding box
```julia
p = BBox(Vec(0.0, 0.0, 0.0), Vec(1.0, 1.0, 1.0))
render(p, wireframe = true, normals = true, color = RGBA(0,1,0,0.5), transparency = true)
```

## Cube

Solid version

```julia
p = SolidCube(length = 1.0, width = 1.0, height = 1.0)
render(p, wireframe = true, normals = true, color = RGBA(0,1,0,0.5), transparency = true)
```

Hollow version

```julia
p = HollowCube(length = 1.0, width = 1.0, height = 1.0)
render(p, wireframe = true, normals = true, color = RGBA(0,1,0,0.5), transparency = true)
```

## Cylinder

Solid version

```julia
p = SolidCylinder(length = 1.0, width = 1.0, height = 1.0, n = 80)
render(p, wireframe = true, normals = true, color = RGBA(0,1,0,0.5), transparency = true)
```

Hollow version

```julia
p = HollowCylinder(length = 1.0, width = 1.0, height = 1.0, n = 40)
render(p, wireframe = true, normals = true, color = RGBA(0,1,0,0.5), transparency = true)
```

## Frustum

Solid version

```julia
p = SolidFrustum(length = 1.0, width = 1.0, height = 1.0, ratio = 0.5, n = 80)
render(p, wireframe = true, normals = true, color = RGBA(0,1,0,0.5), transparency = true)
```

Hollow version

```julia
p = HollowFrustum(length = 1.0, width = 1.0, height = 1.0, ratio = 0.5, n = 40)
render(p, wireframe = true, normals = true, color = RGBA(0,1,0,0.5), transparency = true)
```

## Cone

Solid version

```julia
p = SolidCone(length = 1.0, width = 1.0, height = 1.0, n = 40)
render(p, wireframe = true, normals = true, color = RGBA(0,1,0,0.5), transparency = true)
```

Hollow version

```julia
p = HollowCone(length = 1.0, width = 1.0, height = 1.0, n = 20)
render(p, wireframe = true, normals = true, color = RGBA(0,1,0,0.5), transparency = true)
```


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


# [Dynamic graph creation and manipulation](@id manual_graph)

Alejandro Morales

Centre for Crop Systems Analysis - Wageningen University

## Graphs, Rules and Queries

A model in VPL is a (discrete) dynamical model that describes the time evolution
of one or more entities (i.e. objects of type `graph`). Each graph  (usually
assumed to be an individual plant) is characterized by a series of nodes
(usually organs) that are represented by nodes in a graph. Each node is
defined by its own state, including (if applicable) a description of its geometry,
color, optical propertes, etc. The dynamic simulation of a graph consists of the
creation and destruction of nodes via graph rewriting rules, and changes to
the internal state of its nodes with the help of queries.

The 3D structure of a graph is generated by processing its nodes using a
**Turtle** procedural geometry approach (i.e. inspired on Logo's turtle graphs
as used in L-systems) and following the topology of the graph. This 3D structure
may be used for visualization using a 3D renderer or for simulating  spatial
processes.

VPL does not provide a domain-specific language to implement rules and queries.
Rather, they are defined by functions which are stored in objects of types `Rule`
and `Query`, respectively. Similarly, the nodes of a graph can be of any
user-defined type, as long as the user defines the necessary methods to support
specific functionality (e.g. the `feed!` method to generate geometry).

VPL is designed around data types and methods. Building a model in VPL typically
requires:

* Defining types for the different classes of nodes of a graph
* Creating rules and queries based on these types
* Creating graphs by combining rules and the initial states of the graphs
* Creating additional elements in the scene (e.g. soil)

A simulation in VPL consists of executing rules iteratively and, within each iteration:

* Use queries to select subset of nodes and modify their states.
* Modify graph-level variables directly.
* Use algorithms in VPL to simulate interactions among nodes or between nodes and their environment.

In addition, VPL allows visualizing the results of a simulation by:
* 3D rendering of the generated scenes
* Network graph representing the nodes in the graph

VPL is designed to facilitate modular model development, such as using different
types of graphs in the same simulation, alternative visualizations of the same
scene by mapping internal states of nodes to colors, or including multiple
ray tracers in the same simulation. Users may also create their own data types
that include graphs as fields or to nest graphs within other graphs.

# Graph

A graph is the basic unit of a model in VPL. Three types of data are stored
inside a graph:

* Components of the graph.
* Graph rewriting rules.
* An user-defined object that characterizes the state of a graph besides its nodes (i.e. graph-level variables).

The nodes of a graph are objects created by the user that inherit from the
abstract type `Node`. This abstract type enables describing the relationship
between nodes using a simple algebra for graph construction (see below). A
graph always needs to be initialized by at least one node (i.e. analogous
to the axiom of L-Systems), as otherwise graph rewriting rules could not be
applied.

The creation of a graph is achieved with the constructor `graph(axiom, rules[, vars])`
where `axiom`, `rules` and `vars` are the axiom, a tuple with
the graph rewriting rules and an user-defined object that stores all graph-level
variables, respectively. Note that the last argument is optional. The method
`rewrite!(graph)` takes a graph as input and executes the graph rewriting rules,
updating the internal state of the graph in-place. Note that this method will not
be called implicitly: it is the responsability of the user to decide when to call
this method.

The system is designed to allow rewriting of graphs in parallel, including shared
memory approaches such as multi-threading with the `Threads.@threads` macro. This
is ensured by deep-copying `axiom`, `rules` and `vars` so that changes in one
graph do not affect other graphs that may be built from the same axioms and rules.
If the user wants some state to be shared across graphs, they should define a global
variable that is modified during execution of rules. If such approach is used,
it is the responsibility of the user to ensure that updates to such global variables
are properly locked or executed atomatically.

## Graph-construction algebra

When initializing a graph and when specifying a graph rewriting rule it is
necessary to indicate the topological relationship between the nodes being
added to a graph (i.e. effectively we build graphs by appending sub-graphs). In
order to facilitate the description of these relationships, a simple algebra is
defined for all objects that inherit from `Node`.

The `+` operator indicates a linear parent-child dependency between the operands.
For example, `M() + L()` indicates that the object generated by `L()` is a child
of `M()`. A branching point is introduced by enclosing the children of a node
within `()` and separating the different branches with ",". For example,
`(M(1) + (L(2), L(3)) + M(4) + L(5))` creates a tree that starts with `M(1)`,
has 3 children (`L(2)`, `L(3)` and `M(4)`) and `M(4)` has a child `L(5)`.

A graph always keep tracks of two special nodes: the root and the insertion point.
The root is the node that has no parent. When you use a graph rewriting rule (see
below) to replace a node *a* with a graph that has a root node *b*, the result is
that node *a* is replaced by node *b* and will inherit all the children and parent
from node *a* (plus the children that *b* already had in the replacement graph).

An insertion point is the node of a graph where new nodes will be connected to
when using the `+` operator. Branches do not modify the insertion point of an
existing graph, but linear addition of nodes will always update the insertion
point to the last node. Thus, these two expressions produce the same tree
structure but with different insertion points: `M(1) + (L(2), L(3)) + M(4) + L(5)`
and `M(1) + (L(2), L(3), M(4) + L(5))`. In the first case, the insertion point
becomes the node `L(5)` but in the second case it remains at `M(1)`. Keeping
track of the insertion point of a graph is important when building  a graph in
several steps.

# Rules

Rules consist of directives that define the dynamic evolution of the nodes
that form a graph, by replacing a subset of the nodes by one or more nodes.
Rules are not executed directly by the user. Instead, they are stored in the
graph and executed by the method `rewrite!`. A rule is made of three parts:

* The type of node to be replaced.
* A function to determine whether a candidate node is to be replaced  or not (**lhs** function)
* A function that generates a node or subgraph to use as replacement (**rhs** function).

The first part must always be present, as it represents the minimum information
required to match the rule against nodes inside a graph. This type must be
the concrete type of the node rather an abstract type or union type from
which the node may inherit. The lhs and rhs functions are optional with the
following default values if missing:

* lhs: `x -> true`
* rhs: `x -> nothing`

A rule with a missing lhs will match all the nodes of the specified type. A
rule without an rhs will remove any matched node and all of its children
(recursively, such that the topological tree is pruned).


A `Context` object includes the data stored inside a node plus its relationship
with other nodes in the graph, as well as a reference to the graph-level
variables. In order to extract the data stored in the node use the function
`data()`. In order to extract the object containing all the graph-level variables,
use the method `vars`. The `Context` object may also be used to access other nodes
by walking through the graph (see below).

For rules that do not capture the context of a node, the lhs part
is a function that takes an object of type `Context` and returns `true` or `false`,
whereas the rhs part is a function that takes a `Context` object and returns a
node or subgraph.

Although rules may also be used to update the internal state of a node (i.e.
by creating a new node of the same type but with a different state), this is only
required when the node is an immutable type. Otherwise, one can also (and
it is recommended to) use a query for better performance (see below).

## Matching relationships among nodes

Sometimes the lhs function needs to check the relationships between nodes
inside a graph (e.g. match all leaves that belong to a particular branch of a
graph). In order achieve that, one can use the functions `hasParent()` and `hasChildren()` to
check for inmediate connections (i.e. effectively to check whether the node is a
root or a leaf in the graph) whereas `hasAncestor()` and `hasDescendant()` allow
traversing the graph and finding any connected node that matches a specific query.
If we need to extract the contents of the node, we may use the corresponding
functions `parent()`, `children()`, `ancestor()` and `descendant()`. Note that `children()`
will return all the children nodes as a tuple, but the rest of functions only
return one node at a time. All these functions take a `Context` object as input
and return either `true` or `false` (for the functions that start with `has`) or a
`Context` or tuple of `Context` objects for the functions that extract the actual
connected node. These methods may also be used inside the rhs function of rules.
However, to avoid code repetition (and for performance reasons), it is recommended
to *capture* the `Context` objects of connected in the lhs function and pass
them to the rhs as described below (see below).

 <!-- TODO: Add a table with the inputs and outputs of each graph-related method -->

## Capturing the context of a node

In some scenarios, knowing the relationship between nodes in the graph
is not sufficient, because data stored inside those related nodes is required
in the rhs function of a rule. In those cases, an extra argument to the constructor for a
`Rule` is required (`captures = true`) to indicate that this rule will pass
additional data from the lhs to the rhs function. Then, the lhs function should
return a tuple, where the first element is still `true` or `false` (to indicate
whether the rule matches a node) and the second element is a tuple of
`Context` objects associated to the nodes being matched. If no match occurs,
it is sufficient to return `(false, ())`, where `()` indicates an empty tuple.
The rhs function should then be a function that takes as first argument the
`Context` object of the node being replaced, and an additional argument for
every `Context` object being captured on the lhs function and passed to the rhs
function.

## Execution of rules

Rules are executed in the same order in which they are added to the graph object.
Then, the lhs part of each rule is tested against all nodes of the specified
type in the same order in which they were added to the graph. Similarly, the rhs
part of a rule will be applied to those nodes that matched the lhs part, in
the same order as in the matching.

<!-- TODO: Diagram on rule execution -->

The lhs part of all the rules are executed first and VPL will check that each
node is not matched by more than rule. In case there is more than one match,
an error will be generated. After all the lhs pars are executed, then the rhs parts
are executed on the matched nodes. Although generating an error may seem
restrictive, the  reasoning for this approach is as follows:

* Graph rewriting is, conceptually, a parallel operation, so two rules cannot replace the same node as that would mean the result depends on the order in which the rules are executed.

* New nodes will be generated by graph rewriting rules that could be matched by the lhs of other graph rewriting rules. To guarantee that all rules rewrite the same graph, all nodes that need to be replaced are identified before any rhs function is executed.

In essence, you need to program your model such that it does not rely on any specific order of execution of the graph rewriting rules.

# Query and `apply`

The `apply()` function will apply a `Query` object to a graph and return a list of
nodes that match the query. The main differences between rules and queries is that queries
do not have an rhs part,they are not stored inside the graph and the user
decides when to apply them. Note that that a query does not modify a graph,
it simply returns a collection of nodes matched by it. Another difference is that
a query always return a reference to the data stored  inside the node, rather
than a `Context` object (so no need to use `data()`). Note that if a query is used
to modify the data stored in a node, then the node needs to be a mutable type.

For nodes of immutable type, a graph rewriting rule must be used to replace
the node. This may seem like a limitation but the fact is that, if one needs
to modify the state of an object after it has been created then, by definition,
that object should be of mutable type. If immutability is required for some reason,
one may keep track of associated variables at the graph level, but such kind of
manual book-keeping is not recommended.

A query is useful when the data stored inside the nodes of a graph need to
be modified or when these data are used as input for some function. Unlike in
rules, the order in which queries are applied in the code will affect the result of
the simulation, especially whether they are applied before or after a call to
`rewrite!`. The reasoning for this is that queries are not altering the structure
of a graph (since they do not remove nor create nodes) and multiple queries
can (and often do) match the same node. For example, one query will alter
an internal variable that is then need as input by another query. Thus, whereas
rules implicitly follow a parallel programming paradigm, queries follow a
sequential programming paradigm.

## Direct access to nodes

It is possible to access nodes directly by their internal ID. This should be done
carefully as the internal ID depends on the internal state of VPL and may not
be reproducible across different runs, so only use it for interactive exploration
of a model. It is possible to identify the internal ID of a node by using the
method `draw()` with the default `node_label` method (see section on [Visualization](@ref manual_3d_visualization)).

The internal ID is generated by a counter inside VPL which can be reset by using
`VPL.Core.resetID()`. Once the ID of a node is known, it is possible to access
using bracket notation `[]` on a `Graph` object or any subgraph generated with
the graph construction algebra.

```julia
module L
    using VirtualPlantLab

    struct N <: Node
        val::Int
    end
end
import .L
using VirtualPlantLab
PlantGraphs.reset_id!()
axiom = L.N(1) + (L.N(3), L.N(4)) + L.N(2) + (L.N(5), L.N(6))
data(axiom[2])
```

The bracket notation will return the `Node` object that wraps the data stored
by the user. Notice how the internal ID does not match the value stored in the node, but
rather the order in which the nodes were processed during the construction of
the axiom. In this case that order coincides with reading the code left-to-right
but that will not always be the case. If we create the `Graph` object that
contains the axiom, we can access the node with the same syntax.

```julia
graph = Graph(axiom = axiom)
data(graph[2])
```


# [Julia basic concepts](@id manual_julia)

Alejandro Morales

Centre for Crop Systems Analysis - Wageningen University


# Introduction

This is not a tutorial or introduction to Julia, but a collection of basic
concepts about Julia that are particularly useful to understand VPL.  It is
assumed that the reader has some experience with programming in other languages,
such as Matlab, R or Python. These concepts should be complemented with general
introductory material about Julia, which can be found at the official
[Julia website](https://julialang.org/).

Julia is a dynamic, interactive programming language, like Matlab, R or Python.
Thus, it is very easy to use and learn incrementally. The language is young and
well-designed, with an emphasis on numerical/scientific computation, although it
is starting to occupy some space in areas such as data science and machine
learning. It has a clear syntax and better consistency than some older programming
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

The first time in a Julia session that a method is called, it will take extra
time as the method will have to be compiled (i.e. Julia uses a Just-in-Time
compiler as opposed to an interpreter). Also, the first time you load a package
after installation/update it will take extra time to load due to precompilation
(this reduces JIT compilation times somewhat). Moreover, code editors and notebooks
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

Anonymous functions are useful when passing a function to another function as argument. For example, the function `bar` below allows applying any function `f` to an argument `x`. In this case we could pass any of the variables defined above, or just create an anonymous function in-place.

```julia
function bar(x, f)
    f(x)
end
bar(2.0, x -> x^2)
```

## Types

A Type in Julia is a data structure that can contain one or more fields. Types are used to keep related data together, and to select the right method implementation of a function (see below). It shares some properties of Classes in Object-Oriented Programming, but there are also important differences.

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

We can always check the type of object with the function `typeof`

```julia
typeof(p)
```

If you forget the fields of a type, try to use `fieldnames` in the type (not the object). It will return the name of all the fields it contains (the ":" in front of each name can be ignored)

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

However, when multiple types share analogous functionality, it is possible to group them by "abstract types" from which they can inherit. Note that abstract types do not contain any fields, so inheritance only works for methods. "abstract types are defined by how they act" (C. Rackauckas)

For example, we may define an abstract type `Vec3` as any type for which a distance (`dist`) can be calculated. The default implementation assumes that the type contains fields `x`, `y` and `z`, though inherited methods can always be overridden.

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



# [Ray tracing](@id manual_raytracer)

Alejandro Morales

Centre for Crop Systems Analysis - Wageningen University

## Overview

VPL offers a built-in ray tracer that can be used to simulate the distribution
of irradiance within a 3D scene. It is a Monte Carloy ray tracer written 100%
in Julia with the following features:

 - Multiple wavelengths.
 - Most common types of materials and radiation sources are provided, but additional ones can be added by the user.
 - Support for multi-threaded execution.
 - An Bounding Volume Hierarchy to speed up the computation.
 - A grid cloner that duplicates (implicitly) the scene in a grid to approximate large canopies.
 - A Russian roulette mechanism to reduce the number of iterations per ray needed while avoiding introducing biases in the computations.

## How ray tracing works

Rays are generated from the radiation soures. A ray is defined by an origin, a
direction and a ray *payload* that contains the radiant power per wavelength
(this would usually be W or umol/s, but the ray tracer is agnostic with respect
to units). Ray tracing is a recursive process in which a ray is traced through
the scene (by testing whether the ray intersects different parts of the scenes
and triangles in it) until it either hits a triangle in a mesh or leaves the
scene through its boundaries.

When a ray hits a triangle inside a mesh, the ray is
modified according to the `Material` object associated to that triangle (see
below). In most cases this would result in a new ray being generated (either
as reflected or transmitted radiation) which is then traced. Also, in
most cases, a fraction of the radiant power carried by the ray will be transferred
to the `Material` object.

The recursive nature of the ray tracer allows simulating scattering within the
scene and, if multiple wavelengths are used and optical properties vary per
wavelength, also changes in the spectral composition of the radiation (e.g.,
red/far red). As the rays are scattered, their radiant power decreases such that
at some point it is not worth tracing them any further. The user can control the
maximum number of iterations per ray after which termination may be considered
(this is `maxiter` in [`PlantRayTracer.RTSettings`](@ref)).

If `maxiter = 1`, the ray tracer will effectively behave as a *ray caster*,
meaning than only primary rays are traced (e.g., for a field crop, this means
that only direct and diffuse radiation will be simulated, not the scattered
component).

Once `maxiter` is reached though, the ray is not guaranteed to be terminated.
The reason is that terminating all rays will introduce a bias in the results
(i.e., total radiation in the scene will be underestimated), especially when a
large number of raus is simulated. To avoid this, VPL implements a Russian roulette
mechanism that will terminate a ray with a probability (`pkill`) and increase the
payload of the rays that survive. This introduces variance

The ray tracer supports the construction of a bounding volume hierarchy (BVH)
that can be used to speed up the computations (by minimizing the number of ray
triangle intersections), especially for scenes with a  large number of triangles.
The BVH is constructed automatically (see below) but the user can specific some
settings to control its construction. It is also possible to turn off this
structure altogether, in which case all rays will be tested against all triangles.

In order to simulate large canopies, VPL implements a grid cloner that will
duplicated (with minimum memory and computational overhead) the scene in a grid
along the different axes. This is particularly useful for reducing edge effects
without having to simulate a large number of plants (see below for details).

## Usage

To use ray tracing the user will need to define a `Scene` object
(see [`PlantGeomPrimitives.Scene`](@ref)) and the radiation sources (see below) which
are then combined with `RayTracer()`. This results in a `Raytracer` object
that contains all the necessary information to perform the ray tracing. To
actually execute the ray tracing the user will need to call `trace!()` on this
object.

Executing the ray tracer will return the total number of rays that were tracer
(including secondary rays) but the most important change is that radiant power
stored in the `Material` objects in the scene will be updated automatically.
This means that the user will need to store the `Material` objects in a data
structure that is accesible (e.g., within a node in a graph).

Most of the settings for the ray tracer are defined in the `RTSettings` object
which is passed to `RayTracer()` when creating the ray tracer. These settings
include `maxiter` and `pkill` for the Russian roulette, the settings for the
grid cloner and whether the tracing should be run in parallel or not.

## Radiation sources

VPL define radiation sources as a combination of of a *geometry* component and
an *angle* component. The geometry component determines where are the rays being
generated, whereas the angle component determines the direction of the rays. Each
radiation source is thus constructed by specifying the geometry and the angle, plus
the number of rays and radiant power per wavelength to be stored in the ray. See
documentation on [`PlantRayTracer.Source`](@ref) for more details.

The followig geometry components are available in VPL:

   - `PointSource`: All rays are generated from a single point in space.
   - `LineSource`: All rays are generated from a line in space.
   - `AreaSource`: All rays are generated from the surface of a user-defined mesh.

The following angle components are available in VPL:

   - `FixedSource`: All rays have the same direction.
   - `LambertianSource`: The direction of the rays follows Lambert's cosine law.
This means that the irradiance is the same when viewed from any angle.

A special type of radiation source is the `DirectionalSource` which is used to
simulate solar radiation. Rays from this source are generated from the upper face
of the scene bounding box and their direction is defined in polar coordinates
(i.e., by a zenith and azimuth angle). Because of the way directional sources
are implemented it is recommended that a grid cloner is used (this is the
default) as otherwise there will parts of the scene that will recieve no rays.
See documentation on [`PlantRayTracer.DirectionalSource`](@ref)
for more details.

## Materials

Several types of materials are available for ray tracing, which all inherit from
the `Material` abstract type. The materials play two roles: (i) they define the
optical properties of the surface (i.e., reflectance and transmittance) for
the different wavelengths being simulated, and (ii) store the radiant power
absorbed by the surface. If the radiant power of a surface is needed, it is
important that the material object is stored in a data structure that the user
can have access to (e.g., within a node in a graph) as the raytracer will simply
modify in-place (without creating a copy) the material object when a ray is absorbed.
The radiant power in a material can be retrieved by applying `power()` to the object.

Materials are added to the scene at ther same time as the geometry either via
`feed()` or `add!()`. It is possible to add one material per mesh (in which case
all triangles within that mesh will share the same material object) or one material
per triangle. In either case, VPL will take care of creating the corresponding
association between the material and the triangles.

VPL will not check that the number of wavelengths in the material matches the
equivalent number in the radiation source or that the same ordering is used.
This is entirely up to the user.

The following material types are available in VPL:

   - `Black`: A material that absorbs all the rays that hit it (equivalent to no
reflectance or transmittance). It is not a realistic material but it is useful
for debugging purposes or for special uses of a ray tracer (e.g., to compute
ground cover).

   - `Sensor`: A material that registers the rays that hit and their radian power
but it does not alter the radiant power or the direction of the rays themselves.
This is useful for measuring the distribution of irradiance within canopy without
disturbing the system. Note that a `Sensor` will not add to the scattering counter
either so there is no need to modify the settings of the Russian roulette.

   - `Lambertian`: A material that describes a perfect diffuser with user-defined
reflectance and transmittance per wavelength.

   - `Phong`: A modified Phong material that implements the equations by
[Lafortune & Willems (1994)](https://www.cs.princeton.edu/courses/archive/fall03/cs526/papers/lafortune94.pdf).
Reflectance is modelled as a combination of a diffuse and a specular component per
wavelength.

## Acceleration of ray tracing

In order to accelerate the tracing of rays within the 3D scene, a [bounding
volume hierarchy](https://en.wikipedia.org/wiki/Bounding_interval_hierarchy) may be used by setting `acceleration = BVH` in the call to
`RayTracer()`. This will create a series of nested [axis-aligned bounding boxes](https://en.wikipedia.org/wiki/Bounding_volume)
organized as a binary tree. The purpose of this structure is to reduce the
number of triangles that need to be tested against each ray (i.e., if a ray
does not intersect a particular box, it will not intersect any of the triangles
inside of it). This does add some additional cost due to the need to test the
intersection of rays against the bounding boxes, but ideally this is much less
than the cost of testing against all the excluded triangles.

The tree is constructed by recursively splitting
each box into two halves and allocating the different triangles in the mesh
to the corresponding boxes. Two rules are available for splitting the boxes,
which must also be specified in the call to `RayTracer()`:

- `rule = AvgSplit(N, L)`: It splits each node along the longest axis at the
average coordinate of the triangles in the node. The splitting is repeated
until the number of triangles in a node is lessor equal than `N` or the total
number of recursive splits (i.e., the depth of the binary tree) reaches `L`.

- `rule = SAH{K}(N, L)`: It splits each node using the [Surface Area Heuristic](https://medium.com/@bromanz/how-to-create-awesome-accelerators-the-surface-area-heuristic-e14b5dec6160)
that defines the expected computation of ray tracing a splitted node versus not
doing it. This method computes the cost of splitting each box along each of its
three axes at different positions given by the value `K`. When `K = 1` the split
occurs at the median of the triangles in the box. For `K > 1` the splits occur at
different quantiles of the triangles in the box. The splitting is repeated
until the number of triangles in a node is lessor equal than `N` or the total
number of recursive splits reaches `L` or the cost of splitting a node exceeds
the cost of not splitting it.

For debugging purposes (or for very small scenes), the user may also specify
`acceleration = Naive` which will basically not implement any acceleration
structured and all rays will be tested against all triangles.

The acceleration structure is created from a `Scene` object via the `accelerate()`
function, and allows specifying the `acceleration` and `rule` arguments. This will
also be responsible of translating the triangular mesh into the data structure
used by the ray tracer (triangles in [barycentric coordinates](https://en.wikipedia.org/wiki/Barycentric_coordinate_system)) as well as fitting
a grid cloner to the scene (see below).

## Grid cloner for edge effects

The grid cloner is used to minimize border effects when tracing rays from the
sources towards the scene. The grid cloner is a form of [geometric *instancing*](https://en.wikipedia.org/wiki/Geometry_instancing)
where the same scene is repeated multiple times along the X, Y or Z direction. In
practice, to avoid excessive memory usage, the scene is not actually replicated
but rather the rays positions are modified to emulate the effect of
the scene being repeated.

In order a grid cloner structure on top of a scene, the user needs to specify
the number of duplications to perform in each direction (`nx`, `ny` and `nz`) as well as the
offsets between the different copies (`dx`, `dy` and `dz`). The
grid cloner is created from a `Scene` object via the `accelerate()` function, but
the settings to control the grid cloner must be set when creating the
`RTSettings` object.

By default, the grid cloner is enabled in the X and Y directions
by replicating the scene three times in each direction (this means creating a grid of
7 x 7 = 49 copies of the scene including the original). The offsets between
the copies are set by default
to width of the scene in the X and Y directions such that there is no overlapping.
The grid cloner is disabled in the Z direction by default.

Note that whereas a grid cloner will not increase significantly the memory used
by the ray tracer, it will increase ray tracing times as fewer rays will be able
to leave the scene. On the other hand, a small (or no) grid cloner will create
an edge effect such that only plants in the center of the scene will be able to
capture the behaviour within a large canopy.

The actual number of copies to use
will depend on plant dimension and solar angles, so a general recommendation is
not possible. Regarding the offsets, these would be related to the sowing/planting
pattern in the case of plant production systems on a regular grid and in many case
this would mean that the copies overlap (and this would be correct) so the defaults
should be overriden in most cases. Using a grid cloner should not be substitute
for using a sufficient number of plants in the scene in order to capture the
plant-to-plant variability, but simply to avoid edge effects.



# [3D visualization](@id manual_3d_visualization)

Alejandro Morales

Centre for Crop Systems Analysis - Wageningen University


# Introduction

VPL has two forms of visualization that are specific to a model: (i) a network representation of the graph via `draw()` and (ii) a 3D rendering of a graph or scene via `render()`. Both forms of visualization rely on the [Makie](https://makie.juliaplots.org/stable/) visualization ecosystem built into Julia. Makie allows for different backends that are relevant in different context of code execution. The backends are automatically chosen based on which Makie backend the user exports. For example if the user runs the following:

```julia
import GLMakie
```

then the native OpenGL backend will be used. Another possible backend is `WGLMakie` which will use WebGL that will render the results in an interactive web environment (this is meant to the used in interactive notebooks or special code editors such as VS Code). Finally, the `CairoMakie` backend will generate vector graphics that can be exported to pdf or svg files (not interactive). It is also possible to export static versions of any visualization in a wide range of formats (see section on [Export visualization](#exporting-visualization)).

# Drawing graphs

The function `draw()` can be applied to a `Graph` object or any subgraph (e.g.,
the axiom of graph) to visualize the network structure. This will produce a
static 2D representation of the graph.
By default, each node will be labelled with the type of object stored in it
(e.g., a turtle movement object or an user-defined object) and the internal ID
that the object has in the graph.

For example, a simple graph would be as follows:

```julia
module L
    using VirtualPlantLab

    struct N <: Node end
end
import .L
using VirtualPlantLab
import GLMakie
axiom = L.N() + (L.N(), L.N()) + L.N() + (L.N(), L.N())
draw(axiom)
graph = Graph(axiom = axiom)
draw(graph)
```

See section on [Graphs](@ref manual_graph)) and how to access nodes directly from their
internal ID for more details.

# 3D visualization

A `Scene` can be rendered in 3D using the function `render()`. To facilitate
usage, the function `render()` can be applied to a `Graph` object or an array
of `Graph` objects and it will automatically generated the corresponding `Scene`
object internally. It can also be applied to a 3D mesh (e.g., the result of a
primitive constructor, see section on [Primitives](@ref manual_primitives)).

When a mesh is being rendered directly, a default color will be used for the
mesh that the user can override (see API documentation for [`PlantViz.render`](@ref)).
Otherwise, `render()` will use the corresponding colors stored in the scene. It
is also possible to add a mesh to an existing 3D visualization by using `render!()`.

For debugging purposes, the `render()` function also allows to visualize the
edges of the triangles (`wireframe = true`) and the normal vectors (`normals = true`).

When `render()` is applied to a `Graph` object or array of `Graph` objects, it
will create internally a `Turtle` object to traverse the graph and generate the
`Scene` object. The `feed`
method takes an optional `message` argument that the user may use to control
the generation of geometry and/or colors. The `render` function allows to define
such message (any user-defined data) which will be passed along to the `feed`
methods.

Ultimately, `render()` will call the Makie function `mesh()` (or `mesh!()` for
`render!()`) and the `Figure` object from Makie. This means that any keyword argument
that is accepted by `mesh()` or `mesh!()` can be used to `render()` or `render!()`.
It also means that the use can access and modify the `Figure()` object being returned.
For example, it is possible to change the camera position, lighting, etc.
See [Makie documentation](https://docs.makie.org/stable/) for details.

# Visualization in context

Depending on the context and backend used, a different form of visualization will be obtained. The different scenarios are described below:

## Terminal

This means the code is ran from within the Julia REPL inside a terminal or command prompt (i.e., no IDE or notebook environment):

* Using the native backend will trigger an external window (entitled *Makie*) where an interactive OpenGL visualization will be rendered. The interactivity provided allows zooming and moving the camera around the visualization.

* Using the web backend will open a browser tab (unless there are some OS settings preventing, in which case a local IP address will be printed to the REPL and the user will have to manually input it into the browser) which an intetactive WebGL version will be rendered. The behaviour will be analogous to the natibe backend but note that this backend is still experimental (at the time of writing this documentation) so one should expect the ocasional bug.

* The vector backend will not display any visual output in this context. One can still export the resulting figure (see section on [Export visualization](#exporting-visualization)).

## Live interactive notebook

This means the code is running withn a Jupyter or Pluto notebook and they an active kernel or Julia session running in the background. Note that a notebook that is stored online will not be live unless it is hosted by a server that can run notebooks such as Binder or Google colab.

* The native backend will produce an inline visualization (i.e., the visualization output shows below the code cell). This will however create a static image of the 2D or 3D with the initial camera settings (not interactive).

* The web backend will generate the visualization output below the code cell and it will be interactive as long as the kernel or background Julia session keeps running.

* The vector backend will display the static output next to the code cell (but only if it is using the svg engine, which is the default).

## Visual Studio Code

IDEs that support Julia such as [Visual Studio Code](https://code.visualstudio.com/) will generally have a plot pane where visualization output is stored. This can generally be turn off (in which case the behaviour of the IDE will be the same as running from a terminal). VPL has been tested with Visual Studio Code and the [Julia extension](https://marketplace.visualstudio.com/items?itemName=julialang.language-julia) and, if the plot pane is active, the behaviour will be equivalent to a live interative notebook:

* The native backend will trigger an external window rather than in the plot pane.

* The web backend will generate the visualization output in the plot pane and it will be interactive.

* The vector backend will generate the static visualization output in the plot pane.

## Document generation

This category includes a file that is processed by [Quarto](https://quarto.org/), [Documenter](https://juliadocs.github.io/Documenter.jl/stable/), [Weave](http://weavejl.mpastell.com/stable/) or [Literate](https://fredrikekre.github.io/Literate.jl/v2/). In all of these cases the final output will remain static while the visualization output should be generated inline (i.e., next to the code chunk). The following behavior has been observed with Quarto (other document generation methods have not been fully tested with VPL but are expected to behave similarly):

* For the native backend, a static snapshot of the visualization will always be inlined. The result would be as in the inline visualization of interactive notebooks.

* The web backend will not generate any visualization in the final document as this backend always requires interactivity.

* The vector backend will display the static ouput as in interactive notebooks.

## On a headless server

It will be possible to use the visualization tools even when running VPL in a headless system (e.g., a high performance computing cluster). The folliowing is based on the documentation on Makie, it has not been tested with VPL:

* The native backend will require X11 forwarding to render on the local machine or use [VirtualGL](https://www.virtualgl.org/) technology.

* The web backend will work if a Javascript serve is setup to serve the HTML content from the remote system (see [here](https://makie.juliaplots.org/stable/documentation/headless/#wglmakie) for details).

* The vector backend will generate the images correctly but the user will have to export them to pdf or svg files.

# Exporting visualization

It is possible to save any visualization generated by VPL as an external file with the `export_graph()` and `export_scene()` functions (for graph and scene visualizations, respectively). The file formats supported are png (when using `native` and `web` backends), pdf and svg (when using `vector` backend). This is possible by assigning the object returned by `draw()` or `render()` to a variable and passing that variable to the corresponding export function. This object contains all the information related to the visualization and printing it (i.e., sending it to the Julia REPL) actually causes the visualization to be created. That is, the following code:

```julia
draw(graph)
```

is equivalent to:

```julia
f = draw(graph);
f
```

Remember that `;` will prevent printing the output of whatever Julia command was executed. Saving the graph is a matter of passing `f` to `export_graph()` and assign it a file name with extension:

```julia
f = draw(graph);
export_graph(f, "<filename>.<ext>")
```

If you generate an interactive visualization, you can remove the `;` which will trigger the visualization (inlined or in an external screen) while also saving a reference to the figure inside `f`. The user may then interact with the figure (e.g., zoom in and pan around), which will automatically update `f`. That is, whatever you see on the screen will be saved to the external file. For example, rhis allows the user to save the same scene from different perspectives in separate files. The vector formats (pdf and svg) are only compatible with the `vector` backend, which does not offer interactivity. Hence, this functionality is only available for png files that will save the graph or scene generated by the `native` or `web` backends.

When drawing a graph or rendering a scene it is possible specify the resolution of the generated image as tuple of two numbers such as `resolution = (800, 600)`. In the case of `web` and `native` backends, the resolution is the actual pixels being used, whereas for the `vector` backend it is related to the actual dimensions of the figure in *points*. When the user sabes a graph or scene into an external file, the resolution may have to be chosen based on the intended physical dimensions of the figure (on screen or printed). For png images, the conversion from pixel resolution to physical dimensions is captured by the dpi (*dots per inch*) chosen at the moment of printing or displaying. In the case of vector images, as indicated before, the conventions are 1 Makie unit = 0.75 pt and 1 inch = 72 pt (these are conventions borrowed from web development such that svg images can be converted to png with altering the actual size of the image on the website). To help users, VPL offers the function `calculate_resolution()` which will compute the resolution to be used by `draw()` or `render()` in order to guarantee a particular dimension of the final exported output expressed as `width` and `height` (in cm). If we want to save the image as a png we have to specify the intended dpi:

```julia
# Compute pixel resolution to ensure a width of 6 cm, height of 16 cm and a dpi of 300
res = calculate_resolution(height = 6, width = 16, dpi = 300)
f = draw(graph, resolution = res);
using FileIO # General package for exporting or importing image files
save("<filename>.png", f)
```

In the case of vector formats, we only need to specify the width and height as the conversion between physical dimensions and pixel resolution is fixed, but we will need to specify the correct format:

```julia
# Compute pixel resolution to ensure a width of 6 cm, height of 16 cm and a dpi of 300
res = calculate_resolution(height = 6, width = 16, format = "svg")
f = draw(graph, resolution = res);
import CairoMakie # Needed to save as svg or pdf
save("<filename>.svg", f)
```

Regarding dpi, please consider that the dpi is not a property of a png image (some software include a dpi header in the image metadata, but VPL will not). It is still the responsibility of the user to ensure that the image is printed (or inserted in some document) with the correct dimensions. The `calculate_resolution()` function will simply guarantee that, once the user enforces those dimensions, the image will have the correct dpi.


# Algae growth

Alejandro Morales

Centre for Crop Systems Analysis - Wageningen University

In this first example, we learn how to create a `Graph` and update it
dynamically with rewriting rules.

The model described here is based on the non-branching model of [algae
growth](https://en.wikipedia.org/wiki/L-system#Example_1:_Algae) proposed by
Lindermayer as one of the first L-systems.

First, we need to load the VPL metapackage, which will automatically load all
the packages in the VPL ecosystem.

````julia
using VirtualPlantLab
````

The rewriting rules of the L-system are as follows:

**axiom**:   A

**rule 1**:  A $\rightarrow$ AB

**rule 2**:  B $\rightarrow$ A

In VPL, this L-system would be implemented as a graph where the nodes can be of
type `A` or `B` and inherit from the abstract type `Node`. It is advised to
include type definitions in a module to avoid having to restart the Julia
session whenever we want to redefine them. Because each module is an independent
namespace, we need to import `Node` from the VPL package inside the module:

````julia
module algae
    import VirtualPlantLab: Node
    struct A <: Node end
    struct B <: Node end
end
import .algae
````

Note that in this very example we do not need to store any data or state inside
the nodes, so types `A` and `B` do not require fields.

The axiom is simply defined as an instance of type of `A`:

````julia
axiom = algae.A()
````

The rewriting rules are implemented in VPL as objects of type `Rule`. In VPL, a
rewriting rule substitutes a node in a graph with a new node or subgraph and is
therefore composed of two parts:

1. A condition that is tested against each node in a graph to choose which nodes
   to rewrite.
2. A subgraph that will replace each node selected by the condition above.

In VPL, the condition is split into two components:

1. The type of node to be selected (in this example that would be `A` or `B`).
2. A function that is applied to each node in the graph (of the specified type)
   to indicate whether the node should be selected or not. This function is
   optional (the default is to select every node of the specified type).

The replacement subgraph is specified by a function that takes as input the node
selected and returns a subgraph defined as a combination of node objects.
Subgraphs (which can also be used as axioms) are created by linearly combining
objects that inherit from `Node`. The operation `+` implies a linear
relationship between two nodes and `[]` indicates branching.

The implementation of the two rules of algae growth model in VPL is as follows:

````julia
rule1 = Rule(algae.A, rhs = x -> algae.A() + algae.B())
rule2 = Rule(algae.B, rhs = x -> algae.A())
````

Note that in each case, the argument `rhs` is being assigned an anonymous (aka
*lambda*) function. This is a function without a name that is defined directly
in the assigment to the argument. That is, the Julia expression `x -> A() + B()`
is equivalent to the following function definition:

````julia
function rule_1(x)
    algae.A() + algae.B()
end
````

For simple rules (especially if the right hand side is just a line of code) it
is easier to just define the right hand side of the rule with an anonymous
function rather than creating a standalone function with a meaningful name.
However, standalone functions are easier to debug as you can call them directly
from the REPL.

With the axiom and rules we can now create a `Graph` object that represents the
algae organism. The first argument is the axiom and the second is a tuple with
all the rewriting rules:

````julia
organism = Graph(axiom = axiom, rules = (rule1, rule2))
````

If we apply the rewriting rules iteratively, the graph will grow, in this case
representing the growth of the algae organism. The rewriting rules are applied
on the graph with the function `rewrite!()`:

````julia
rewrite!(organism)
````

Since there was only one node of type `A`, the only rule that was applied was
`rule1`, so the graph should now have two nodes of types `A` and `B`,
respectively. We can confirm this by drawing the graph. We do this with the
function `draw()` which will always generate the same representation of the
graph, but different options are available depending on the context where the
code is executed. By default, `draw()` will create a new window where an
interactive version of the graph will be drawn and one can zoom and pan with the
mouse (in this online document a static version is shown, see
[Backends](../manual/Visualization.md) for details):

````julia
import GLMakie
draw(organism)
````

Notice that each node in the network representation is labelled with the type of
node (`A` or `B` in this case) and a number in parenthesis. This number is a
unique identifier associated to each node and it is useful for debugging
purposes (this will be explained in more advanced examples).

Applying multiple iterations of rewriting can be achieved with a simple loop:

````julia
for i in 1:4
    rewrite!(organism)
end
````

And we can verify that the graph grew as expected:

````julia
draw(organism)
````

The network is rather boring as the system is growing linearly (no branching)
but it already illustrates how graphs can grow rapidly in just a few iterations.
Remember that the interactive visualization allows adjusting the zoom, which is
handy when graphs become large.

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*



# Context sensitive rules

Alejandro Morales

Centre for Crop Systems Analysis - Wageningen University

This examples goes back to a very simple situation: a linear sequence of 3
cells. The point of this example is to introduce relational growth rules and
context capturing.

A relational rules matches nodes based on properties of neighbouring nodes in
the graph. This requires traversing the graph, which can be done with the
methods `parent` and `children` on the `Context` object of the current node,
which return a list of `Context` objects for the parent or children nodes.

In some cases, it is not only sufficient to query the neighbours of a node but
also to use properties of those neighbours in the right hand side component of
the rule. This is know as "capturing the context" of the node being updated.
This can be done by returning the additional nodes from the `lhs` component (in
addition to `true` or `false`) and by accepting these additional nodes in the
`rhs` component. In addition, we tell VPL that this rule is capturing the
context with `captures = true`.

In the example below, each `Cell` keeps track of a `state` variable (which is
either 0 or 1). Only the first cell has a state of 1 at the beginning. In the
growth rule, we check the father of each `Cell`. When a `Cell` does not have a
parent, the rule does not match, otherwise, we pass capture the parent node. In
the right hand side, we replace the cell with a new cell with the state of the
parent node that was captured. Note that that now, the rhs component gets a new
argument, which corresponds to the context of the father node captured in the
lhs.

````julia
using VirtualPlantLab
module types
    using VirtualPlantLab
    struct Cell <: Node
        state::Int64
    end
end
import .types: Cell
function transfer(context)
    if has_parent(context)
        return (true, (parent(context), ))
    else
        return (false, ())
    end
end
rule = Rule(Cell, lhs = transfer, rhs = (context, father) -> Cell(data(father).state), captures = true)
axiom = Cell(1) + Cell(0) + Cell(0)
pop = Graph(axiom = axiom, rules = rule)
````

In the original state defined by the axiom, only the first node contains a state
of 1. We can retrieve the state of each node with a query. A `Query` object is a
like a `Rule` but without a right-hand side (i.e., its purpose is to return the
nodes that match a particular condition). In this case, we just want to return
all the `Cell` nodes. A `Query` object is created by passing the type of the
node to be queried as an argument to the `Query` function. Then, to actually
execute the query we need to use the `apply` function on the graph.

````julia
getCell = Query(Cell)
apply(pop, getCell)
````

If we rewrite the graph one we will see that a second cell now has a state of 1.

````julia
rewrite!(pop)
apply(pop, getCell)
````

And a second iteration results in all cells have a state of 1

````julia
rewrite!(pop)
apply(pop, getCell)
````

Note that queries may not return nodes in the same order as they were created
because of how they are internally stored (and because queries are meant to
return collection of nodes rather than reconstruct the topology of a graph). If
we need to process nodes in a particular order, then it is best to use a
traversal algorithm on the graph that follows a particular order (for example
depth-first traversal with `traverse_dfs()`). This algorithm requires a function
that applies to each node in the graph. In this simple example we can just store
the `state` of each node in a vector (unlike Rules and Queries, this function
takes the actual node as argument rather than a `Context` object, see the
documentation for more details):

````julia
pop  = Graph(axiom = axiom, rules = rule)
states = Int64[]
traverse_dfs(pop, fun = node -> push!(states, node.state))
states
````

Now the states of the nodes are in the same order as they were created:

````julia
rewrite!(pop)
states = Int64[]
traverse_dfs(pop, fun = node -> push!(states, node.state))
states
````

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*



# Forest

Alejandro Morales

Centre for Crop Systems Analysis - Wageningen University

In this example we extend the tree example into a forest, where
each tree is described by a separate graph object and parameters driving the
growth of these trees vary across individuals following a predefined distribution.
The data types, rendering methods and growth rules are the same as in the binary
tree example:

````julia
using VirtualPlantLab
using Distributions, Plots, ColorTypes
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
        length::Float64 = 0.10 # Internodes start at 10 cm
    end
    # Leaf
    Base.@kwdef struct Leaf <: VirtualPlantLab.Node
        length::Float64 = 0.20 # Leaves are 20 cm long
        width::Float64  = 0.1 # Leaves are 10 cm wide
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

import .TreeTypes
````

Create geometry + color for the internodes

````julia
function VirtualPlantLab.feed!(turtle::Turtle, i::TreeTypes.Internode, data)
    # Rotate turtle around the head to implement elliptical phyllotaxis
    rh!(turtle, data.phyllotaxis)
    HollowCylinder!(turtle, length = i.length, height = i.length/15, width = i.length/15,
                move = true, color = RGB(0.5,0.4,0.0))
    return nothing
end
````

Create geometry + color for the leaves

````julia
function VirtualPlantLab.feed!(turtle::Turtle, l::TreeTypes.Leaf, data)
    # Rotate turtle around the arm for insertion angle
    ra!(turtle, -data.leaf_angle)
    # Generate the leaf
    Ellipse!(turtle, length = l.length, width = l.width, move = false,
             color = RGB(0.2,0.6,0.2))
    # Rotate turtle back to original direction
    ra!(turtle, data.leaf_angle)
    return nothing
end
````

Insertion angle for the bud nodes

````julia
function VirtualPlantLab.feed!(turtle::Turtle, b::TreeTypes.BudNode, data)
    # Rotate turtle around the arm for insertion angle
    ra!(turtle, -data.branch_angle)
end
````

Rules

````julia
meristem_rule = Rule(TreeTypes.Meristem, rhs = mer -> TreeTypes.Node() +
                                              (TreeTypes.Bud(), TreeTypes.Leaf()) +
                                         TreeTypes.Internode() + TreeTypes.Meristem())

function prob_break(bud)
    # We move to parent node in the branch where the bud was created
    node =  parent(bud)
    # We count the number of internodes between node and the first Meristem
    # moving down the graph
    check, steps = has_descendant(node, condition = n -> data(n) isa TreeTypes.Meristem)
    steps = Int(ceil(steps/2)) # Because it will count both the nodes and the internodes
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
````

The main difference with respect to the tree is that several of the parameters
will vary per TreeTypes. Also, the location of the tree and initial orientation of
the turtle will also vary. To achieve this we need to:

(i) Add two additional initial nodes that move the turtle to the starting position
of each tree and rotates it.

(ii) Wrap the axiom, rules and the creation of the graph into a function that
takes the required parameters as inputs.

````julia
function create_tree(origin, growth, budbreak, orientation)
    axiom = T(origin) + RH(orientation) + TreeTypes.Internode() + TreeTypes.Meristem()
    tree =  Graph(axiom = axiom, rules = (meristem_rule, branch_rule),
                  data = TreeTypes.treeparams(growth = growth, budbreak = budbreak))
    return tree
end
````

The code for elongating the internodes to simulate growth remains the same as for
the binary tree example

````julia
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

function simulate(tree, query, nsteps)
    new_tree = deepcopy(tree)
    for i in 1:nsteps
        growth!(new_tree, query)
    end
    return new_tree
end
````

Let's simulate a forest of 10 x 10 trees with a distance between (and within) rows
of 2 meters. First we generate the original positions of the trees. For the
position we just need to pass a `Vec` object with the x, y, and z coordinates of
the location of each TreeTypes. The code below will generate a matrix with the coordinates:

````julia
origins = [Vec(i,j,0) for i = 1:2.0:20.0, j = 1:2.0:20.0]
````

We may assume that the initial orientation is uniformly distributed between 0 and 360 degrees:

````julia
orientations = [rand()*360.0 for i = 1:2.0:20.0, j = 1:2.0:20.0]
````

For the `growth` and `budbreak` parameters we will assumed that they follow a
LogNormal and Beta distribution, respectively. We can generate random
values from these distributions using the `Distributions` package. For the
relative growth rate:

````julia
growths = rand(LogNormal(-2, 0.3), 10, 10)
histogram(vec(growths))
````

And for the budbreak parameter:

````julia
budbreaks = rand(Beta(2.0, 10), 10, 10)
histogram(vec(budbreaks))
````

Now we can create our forest by calling the `create_tree` function we defined earlier
with the correct inputs per tree:

````julia
forest = vec(create_tree.(origins, growths, budbreaks, orientations));
````

By vectorizing `create_tree()` over the different arrays, we end up with an array
of trees. Each tree is a different Graph, with its own nodes, rewriting rules
and variables. This avoids having to create a large graphs to include all the
plants in a simulation. Below we will run a simulation, first using a sequential
approach (i.e. using one core) and then using multiple cores in our computers (please check
https://docs.julialang.org/en/v1/manual/multi-threading/ if the different cores are not being used
as you may need to change some settings in your computer).

## Sequential simulation

We can simulate the growth of each tree by applying the method `simulate` to each
tree, creating a new version of the forest (the code below is an array comprehension)

````julia
newforest = [simulate(tree, getInternode, 2) for tree in forest];
````

And we can render the forest with the function `render` as in the binary tree
example but passing the whole forest at once

````julia
render(Scene(newforest))
````

If we iterate 4 more iterations we will start seeing the different individuals
diverging in size due to the differences in growth rates

````julia
newforest = [simulate(tree, getInternode, 15) for tree in newforest];
render(Scene(newforest))
````

## Multithreaded simulation

In the previous section, the simulation of growth was done sequentially, one tree
after another (since the growth of a tree only depends on its own parameters). However,
this can also be executed in multiple threads. In this case we use an explicit loop
and execute the iterations of the loop in multiple threads using the macro `@threads`.
Note that the rendering function can also be ran in parallel (i.e. the geometry will be
generated separately for each plant and the merge together):

````julia
using Base.Threads
newforest = deepcopy(forest)
@threads for i in eachindex(forest)
    newforest[i] = simulate(forest[i], getInternode, 6)
end
render(Scene(newforest), parallel = true)
````

An alternative way to perform the simulation is to have an outer loop for each timestep and an internal loop over the different trees. Although this approach is not required for this simple model, most FSP models will probably need such a scheme as growth of each individual plant will depend on competition for resources with neighbouring plants. In this case, this approach would look as follows:

````julia
newforest = deepcopy(forest)
for step in 1:15
    @threads for i in eachindex(newforest)
        newforest[i] = simulate(newforest[i], getInternode, 1)
    end
end
render(Scene(newforest), parallel = true)
````

# Customizing the scene

Here we are going to customize the scene of our simulation by adding a horizontal tile represting soil and
tweaking the 3D representation. When we want to combine plants generated from graphs with any other
geometric element it is best to combine all these geometries in a `GLScene` object. We can start the scene
with the `newforest` generated in the above:

````julia
scene = Scene(newforest);
````

We can create the soil tile directly, without having to create a graph. The simplest approach is two use
a special constructor `Rectangle` where one species a corner of the rectangle and two vectors defining the
two sides of the vectors. Both the sides and the corner need to be specified with `Vec` just like in the
above when we determined the origin of each plant. VPL offers some shortcuts: `O()` returns the origin
(`Vec(0.0, 0.0, 0.0)`), whereas `X`, `Y` and `Z` returns the corresponding axes and you can scale them by
passing the desired length as input. Below, a rectangle is created on the XY plane with the origin as a
corner and each side being 11 units long:

````julia
soil = Rectangle(length = 21.0, width = 21.0)
rotatey!(soil, pi/2)
VirtualPlantLab.translate!(soil, Vec(0.0, 10.5, 0.0))
````

We can now add the `soil` to the `scene` object with the `add!` function.

````julia
VirtualPlantLab.add!(scene, mesh = soil, color = RGB(1,1,0))
````

We can now render the scene that combines the random forest of binary trees and a yellow soil. Notice that
in all previous figures, a coordinate system with grids was being depicted. This is helpful for debugging
your code but also to help setup the scene (e.g. if you are not sure how big the soil tile should be).
Howver, it may be distracting for the visualization. It turns out that we can turn that off with
`show_axes = false`:

````julia
render(scene, axes = false)
````

We may also want to save a screenshot of the scene. For this, we need to store the output of the `render` function.
We can then resize the window rendering the scene, move around, zoom, etc. When we have a perspective that we like,
we can run the `save_scene` function on the object returned from `render`. The argument `resolution` can be adjusted in both
`render` to increase the number of pixels in the final image. A helper function `calculate_resolution` is provided to
compute the resolution from a physical width and height in cm and a dpi (e.g., useful for publications and posters):

````julia
res = calculate_resolution(width = 16.0, height = 16.0, dpi = 1_000)
output = render(scene, axes = false, resolution = res)
export_scene(scene = output, filename = "nice_trees.png")
````

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*



# Growth forest

Alejandro Morales

Centre for Crop Systems Analysis - Wageningen University


In this example we extend the binary forest example to have more complex, time-
dependent development and growth based on carbon allocation. For simplicity, the
model assumes a constant relative growth rate at the plant level to compute the
biomass increment. In the next example this assumption is relaxed by a model of
radiation use efficiency. When modelling growth from carbon allocation, the
biomass of each organ is then translated in to an area or volume and the
dimensions of the organs are updated accordingly (assuming a particular shape).

The following packages are needed:

````julia
using VirtualPlantLab, ColorTypes
using Base.Threads: @threads
using Plots
import Random
using FastGaussQuadrature
using Distributions
Random.seed!(123456789)
````

## Model definition

### Node types

The data types needed to simulate the trees are given in the following
module. The differences with respect to the previous example are:

    - Meristems do not produce phytomers every day
    - A relative sink strength approach is used to allocate biomass to organs
    - The geometry of the organs is updated based on the new biomass
    - Bud break probability is a function of distance to apical meristem

````julia
# Data types
module TreeTypes
    using VirtualPlantLab
    using Distributions
    # Meristem
    Base.@kwdef mutable struct Meristem <: VirtualPlantLab.Node
        age::Int64 = 0   ## Age of the meristem
    end
    # Bud
    struct Bud <: VirtualPlantLab.Node end
    # Node
    struct Node <: VirtualPlantLab.Node end
    # BudNode
    struct BudNode <: VirtualPlantLab.Node end
    # Internode (needs to be mutable to allow for changes over time)
    Base.@kwdef mutable struct Internode <: VirtualPlantLab.Node
        age::Int64 = 0         ## Age of the internode
        biomass::Float64 = 0.0 ## Initial biomass
        length::Float64 = 0.0  ## Internodes
        width::Float64  = 0.0  ## Internodes
        sink::Exponential{Float64} = Exponential(5)
    end
    # Leaf
    Base.@kwdef mutable struct Leaf <: VirtualPlantLab.Node
        age::Int64 = 0         ## Age of the leaf
        biomass::Float64 = 0.0 ## Initial biomass
        length::Float64 = 0.0  ## Leaves
        width::Float64 = 0.0   ## Leaves
        sink::Beta{Float64} = Beta(2,5)
    end
    # Graph-level variables -> mutable because we need to modify them during growth
    Base.@kwdef mutable struct treeparams
        # Variables
        biomass::Float64 = 2e-3 ## Current total biomass (g)
        # Parameters
        RGR::Float64 = 1.0   ## Relative growth rate (1/d)
        IB0::Float64 = 1e-3  ## Initial biomass of an internode (g)
        SIW::Float64 = 0.1e6 ## Specific internode weight (g/m3)
        IS::Float64  = 15.0  ## Internode shape parameter (length/width)
        LB0::Float64 = 1e-3  ## Initial biomass of a leaf
        SLW::Float64 = 100.0 ## Specific leaf weight (g/m2)
        LS::Float64  = 3.0   ## Leaf shape parameter (length/width)
        budbreak::Float64 = 1/0.5 ## Bud break probability coefficient (in 1/m)
        plastochron::Int64 = 5 ## Number of days between phytomer production
        leaf_expansion::Float64 = 15.0 ## Number of days that a leaf expands
        phyllotaxis::Float64 = 140.0
        leaf_angle::Float64 = 30.0
        branch_angle::Float64 = 45.0
    end
end

import .TreeTypes
````

### Geometry

The methods for creating the geometry and color of the tree are the same as in
the previous example.

````julia
# Create geometry + color for the internodes
function VirtualPlantLab.feed!(turtle::Turtle, i::TreeTypes.Internode, vars)
    # Rotate turtle around the head to implement elliptical phyllotaxis
    rh!(turtle, vars.phyllotaxis)
    HollowCylinder!(turtle, length = i.length, height = i.width, width = i.width,
                move = true, color = RGB(0.5,0.4,0.0))
    return nothing
end

# Create geometry + color for the leaves
function VirtualPlantLab.feed!(turtle::Turtle, l::TreeTypes.Leaf, vars)
    # Rotate turtle around the arm for insertion angle
    ra!(turtle, -vars.leaf_angle)
    # Generate the leaf
    Ellipse!(turtle, length = l.length, width = l.width, move = false,
             color = RGB(0.2,0.6,0.2))
    # Rotate turtle back to original direction
    ra!(turtle, vars.leaf_angle)
    return nothing
end

# Insertion angle for the bud nodes
function VirtualPlantLab.feed!(turtle::Turtle, b::TreeTypes.BudNode, vars)
    # Rotate turtle around the arm for insertion angle
    ra!(turtle, -vars.branch_angle)
end
````

### Development

The meristem rule is now parameterized by the initial states of the leaves and
internodes and will only be triggered every X days where X is the plastochron.

````julia
# Create right side of the growth rule (parameterized by the initial states
# of the leaves and internodes)
function create_meristem_rule(vleaf, vint)
    meristem_rule = Rule(TreeTypes.Meristem,
                        lhs = mer -> mod(data(mer).age, graph_data(mer).plastochron) == 0,
                        rhs = mer -> TreeTypes.Node() +
                                     (TreeTypes.Bud(),
                                     TreeTypes.Leaf(biomass = vleaf.biomass,
                                                    length  = vleaf.length,
                                                    width   = vleaf.width)) +
                                     TreeTypes.Internode(biomass = vint.biomass,
                                                         length  = vint.length,
                                                         width   = vint.width) +
                                     TreeTypes.Meristem())
end
````

The bud break probability is now a function of distance to the apical meristem
rather than the number of internodes. An adhoc traversal is used to compute this
length of the main branch a bud belongs to (ignoring the lateral branches).

````julia
# Compute the probability that a bud breaks as function of distance to the meristem
function prob_break(bud)
    # We move to parent node in the branch where the bud was created
    node =  parent(bud)
    # Extract the first internode
    child = filter(x -> data(x) isa TreeTypes.Internode, children(node))[1]
    data_child = data(child)
    # We measure the length of the branch until we find the meristem
    distance = 0.0
    while !isa(data_child, TreeTypes.Meristem)
        # If we encounter an internode, store the length and move to the next node
        if data_child isa TreeTypes.Internode
            distance += data_child.length
            child = children(child)[1]
            data_child = data(child)
        # If we encounter a node, extract the next internode
        elseif data_child isa TreeTypes.Node
                child = filter(x -> data(x) isa TreeTypes.Internode, children(child))[1]
                data_child = data(child)
        else
            error("Should be Internode, Node or Meristem")
        end
    end
    # Compute the probability of bud break as function of distance and
    # make stochastic decision
    prob =  min(1.0, distance*graph_data(bud).budbreak)
    return rand() < prob
end

# Branch rule parameterized by initial states of internodes
function create_branch_rule(vint)
    branch_rule = Rule(TreeTypes.Bud,
            lhs = prob_break,
            rhs = bud -> TreeTypes.BudNode() +
                         TreeTypes.Internode(biomass = vint.biomass,
                                             length  = vint.length,
                                             width   = vint.width) +
                         TreeTypes.Meristem())
end
````

### Growth

We need some functions to compute the length and width of a leaf or internode
from its biomass

````julia
function leaf_dims(biomass, vars)
    leaf_biomass = biomass
    leaf_area    = biomass/vars.SLW
    leaf_length  = sqrt(leaf_area*4*vars.LS/pi)
    leaf_width   = leaf_length/vars.LS
    return leaf_length, leaf_width
end

function int_dims(biomass, vars)
    int_biomass = biomass
    int_volume  = biomass/vars.SIW
    int_length  = cbrt(int_volume*4*vars.IS^2/pi)
    int_width   = int_length/vars.IS
    return int_length, int_width
end
````

Each day, the total biomass of the tree is updated using a simple RGR formula
and the increment of biomass is distributed across the organs proportionally to
their relative sink strength (of leaves or internodes).

The sink strength of leaves is modelled with a beta distribution scaled to the
`leaf_expansion` argument that determines the duration of leaf growth, whereas
for the internodes it follows a negative exponential distribution. The `pdf`
function computes the probability density of each distribution which is taken as
proportional to the sink strength (the model is actually source-limited since we
imposed a particular growth rate).

````julia
sink_strength(leaf, vars) = leaf.age > vars.leaf_expansion ? 0.0 :
                            pdf(leaf.sink, leaf.age/vars.leaf_expansion)/100.0
plot(0:1:50, x -> sink_strength(TreeTypes.Leaf(age = x), TreeTypes.treeparams()),
     xlabel = "Age", ylabel = "Sink strength", label = "Leaf")

sink_strength(int) = pdf(int.sink, int.age)
plot!(0:1:50, x -> sink_strength(TreeTypes.Internode(age = x)), label = "Internode")
````

Now we need a function that updates the biomass of the tree, allocates it to the
different organs and updates the dimensions of said organs. For simplicity,
we create the functions `leaves()` and `internodes()` that will apply the queries
to the tree required to extract said nodes:

````julia
get_leaves(tree) = apply(tree, Query(TreeTypes.Leaf))
get_internodes(tree) = apply(tree, Query(TreeTypes.Internode))
````

The age of the different organs is updated every time step:

````julia
function age!(all_leaves, all_internodes, all_meristems)
    for leaf in all_leaves
        leaf.age += 1
    end
    for int in all_internodes
        int.age += 1
    end
    for mer in all_meristems
        mer.age += 1
    end
    return nothing
end
````

The daily growth is allocated to different organs proportional to their sink
strength.

````julia
function grow!(tree, all_leaves, all_internodes)
    # Compute total biomass increment
    tvars = data(tree)
    ΔB    = tvars.RGR*tvars.biomass
    tvars.biomass += ΔB
    # Total sink strength
    total_sink = 0.0
    for leaf in all_leaves
        total_sink += sink_strength(leaf, tvars)
    end
    for int in all_internodes
        total_sink += sink_strength(int)
    end
    # Allocate biomass to leaves and internodes
    for leaf in all_leaves
        leaf.biomass += ΔB*sink_strength(leaf, tvars)/total_sink
    end
    for int in all_internodes
        int.biomass += ΔB*sink_strength(int)/total_sink
    end
    return nothing
end
````

Finally, we need to update the dimensions of the organs. The leaf dimensions are

````julia
function size_leaves!(all_leaves, tvars)
    for leaf in all_leaves
        leaf.length, leaf.width = leaf_dims(leaf.biomass, tvars)
    end
    return nothing
end
function size_internodes!(all_internodes, tvars)
    for int in all_internodes
        int.length, int.width = int_dims(int.biomass, tvars)
    end
    return nothing
end
````

### Daily step

All the growth and developmental functions are combined together into a daily
step function that updates the forest by iterating over the different trees in
parallel.

````julia
get_meristems(tree) = apply(tree, Query(TreeTypes.Meristem))
function daily_step!(forest)
    @threads for tree in forest
        # Retrieve all the relevant organs
        all_leaves = get_leaves(tree)
        all_internodes = get_internodes(tree)
        all_meristems = get_meristems(tree)
        # Update the age of the organs
        age!(all_leaves, all_internodes, all_meristems)
        # Grow the tree
        grow!(tree, all_leaves, all_internodes)
        tvars = data(tree)
        size_leaves!(all_leaves, tvars)
        size_internodes!(all_internodes, tvars)
        # Developmental rules
        rewrite!(tree)
    end
end
````

### Initialization

The trees are initialized in a regular grid with random values for the initial
orientation and RGR:

````julia
RGRs = rand(Normal(0.3,0.01), 10, 10)
histogram(vec(RGRs))

orientations = [rand()*360.0 for i = 1:2.0:20.0, j = 1:2.0:20.0]
histogram(vec(orientations))

origins = [Vec(i,j,0) for i = 1:2.0:20.0, j = 1:2.0:20.0];
````

The following initalizes a tree based on the origin, orientation and RGR:

````julia
function create_tree(origin, orientation, RGR)
    # Initial state and parameters of the tree
    vars = TreeTypes.treeparams(RGR = RGR)
    # Initial states of the leaves
    leaf_length, leaf_width = leaf_dims(vars.LB0, vars)
    vleaf = (biomass = vars.LB0, length = leaf_length, width = leaf_width)
    # Initial states of the internodes
    int_length, int_width = int_dims(vars.LB0, vars)
    vint = (biomass = vars.IB0, length = int_length, width = int_width)
    # Growth rules
    meristem_rule = create_meristem_rule(vleaf, vint)
    branch_rule   = create_branch_rule(vint)
    axiom = T(origin) + RH(orientation) +
            TreeTypes.Internode(biomass = vint.biomass,
                             length  = vint.length,
                             width   = vint.width) +
            TreeTypes.Meristem()
    tree = Graph(axiom = axiom, rules = (meristem_rule, branch_rule),
                 data = vars)
    return tree
end
````

## Visualization

As in the previous example, it makes sense to visualize the forest with a soil
tile beneath it. Unlike in the previous example, we will construct the soil tile
using a dedicated graph and generate a `Scene` object which can later be
merged with the rest of scene generated in daily step:

````julia
Base.@kwdef struct Soil <: VirtualPlantLab.Node
    length::Float64
    width::Float64
end
function VirtualPlantLab.feed!(turtle::Turtle, s::Soil, vars)
    Rectangle!(turtle, length = s.length, width = s.width, color = RGB(255/255, 236/255, 179/255))
end
soil_graph = RA(-90.0) + T(Vec(0.0, 10.0, 0.0)) + # Moves into position
             Soil(length = 20.0, width = 20.0) # Draws the soil tile
soil = Scene(Graph(axiom = soil_graph));
render(soil, axes = false)
````

And the following function renders the entire scene (notice that we need to
use `display()` to force the rendering of the scene when called within a loop
or a function):

````julia
function render_forest(forest, soil)
    scene = Scene(vec(forest)) # create scene from forest
    scene = Scene([scene, soil]) # merges the two scenes
    render(scene)
end
````

## Retrieving canopy-level data

We may want to extract some information at the canopy level such as LAI. This is
best achieved with a query:

````julia
function get_LAI(forest)
    LAI = 0.0
    @threads for tree in forest
        for leaf in get_leaves(tree)
            LAI += leaf.length*leaf.width*pi/4.0
        end
    end
    return LAI/400.0
end
````

## Simulation

We can now create a forest of trees on a regular grid:

````julia
forest = create_tree.(origins, orientations, RGRs);
render_forest(forest, soil)
for i in 1:50
    daily_step!(forest)
end
render_forest(forest, soil)
````

And compute the leaf area index:

````julia
get_LAI(forest)
````

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*



# Ray-traced forest

Alejandro Morales

Centre for Crop Systems Analysis - Wageningen University


In this example we extend the forest growth model to include PAR interception a
radiation use efficiency to compute the daily growth rate.

The following packages are needed:

````julia
using VirtualPlantLab, ColorTypes
import GLMakie
using Base.Threads: @threads
using Plots
import Random
using FastGaussQuadrature
using Distributions
using SkyDomes
Random.seed!(123456789)
````

## Model definition

### Node types

The data types needed to simulate the trees are given in the following
module. The difference with respec to the previous model is that Internodes and
Leaves have optical properties needed for ray tracing (they are defined as
Lambertian surfaces).

````julia
# Data types
module TreeTypes
    using VirtualPlantLab
    using Distributions
    # Meristem
    Base.@kwdef mutable struct Meristem <: VirtualPlantLab.Node
        age::Int64 = 0   ## Age of the meristem
    end
    # Bud
    struct Bud <: VirtualPlantLab.Node end
    # Node
    struct Node <: VirtualPlantLab.Node end
    # BudNode
    struct BudNode <: VirtualPlantLab.Node end
    # Internode (needs to be mutable to allow for changes over time)
    Base.@kwdef mutable struct Internode <: VirtualPlantLab.Node
        age::Int64 = 0         ## Age of the internode
        biomass::Float64 = 0.0 ## Initial biomass
        length::Float64 = 0.0  ## Internodes
        width::Float64  = 0.0  ## Internodes
        sink::Exponential{Float64} = Exponential(5)
        material::Lambertian{1} = Lambertian(τ = 0.1, ρ = 0.05) ## Leaf material
    end
    # Leaf
    Base.@kwdef mutable struct Leaf <: VirtualPlantLab.Node
        age::Int64 = 0         ## Age of the leaf
        biomass::Float64 = 0.0 ## Initial biomass
        length::Float64 = 0.0  ## Leaves
        width::Float64 = 0.0   ## Leaves
        sink::Beta{Float64} = Beta(2,5)
        material::Lambertian{1} = Lambertian(τ = 0.1, ρ = 0.05) ## Leaf material
    end
    # Graph-level variables -> mutable because we need to modify them during growth
    Base.@kwdef mutable struct treeparams
        # Variables
        PAR::Float64 = 0.0   ## Total PAR absorbed by the leaves on the tree (MJ)
        biomass::Float64 = 2e-3 ## Current total biomass (g)
        # Parameters
        RUE::Float64 = 5.0   ## Radiation use efficiency (g/MJ) -> unrealistic to speed up sim
        IB0::Float64 = 1e-3  ## Initial biomass of an internode (g)
        SIW::Float64 = 0.1e6 ## Specific internode weight (g/m3)
        IS::Float64  = 15.0  ## Internode shape parameter (length/width)
        LB0::Float64 = 1e-3  ## Initial biomass of a leaf
        SLW::Float64 = 100.0 ## Specific leaf weight (g/m2)
        LS::Float64  = 3.0   ## Leaf shape parameter (length/width)
        budbreak::Float64 = 1/0.5 ## Bud break probability coefficient (in 1/m)
        plastochron::Int64 = 5 ## Number of days between phytomer production
        leaf_expansion::Float64 = 15.0 ## Number of days that a leaf expands
        phyllotaxis::Float64 = 140.0
        leaf_angle::Float64 = 30.0
        branch_angle::Float64 = 45.0
    end
end

import .TreeTypes
````

### Geometry

The methods for creating the geometry and color of the tree are the same as in
the previous example but include the materials for the ray tracer.

````julia
# Create geometry + color for the internodes
function VirtualPlantLab.feed!(turtle::Turtle, i::TreeTypes.Internode, data)
    # Rotate turtle around the head to implement elliptical phyllotaxis
    rh!(turtle, data.phyllotaxis)
    HollowCylinder!(turtle, length = i.length, height = i.width, width = i.width,
                move = true, color = RGB(0.5,0.4,0.0), material = i.material)
    return nothing
end

# Create geometry + color for the leaves
function VirtualPlantLab.feed!(turtle::Turtle, l::TreeTypes.Leaf, data)
    # Rotate turtle around the arm for insertion angle
    ra!(turtle, -data.leaf_angle)
    # Generate the leaf
    Ellipse!(turtle, length = l.length, width = l.width, move = false,
             color = RGB(0.2,0.6,0.2), material = l.material)
    # Rotate turtle back to original direction
    ra!(turtle, data.leaf_angle)
    return nothing
end

# Insertion angle for the bud nodes
function VirtualPlantLab.feed!(turtle::Turtle, b::TreeTypes.BudNode, data)
    # Rotate turtle around the arm for insertion angle
    ra!(turtle, -data.branch_angle)
end
````

### Development

The meristem rule is now parameterized by the initial states of the leaves and
internodes and will only be triggered every X days where X is the plastochron.

````julia
# Create right side of the growth rule (parameterized by the initial states
# of the leaves and internodes)
function create_meristem_rule(vleaf, vint)
    meristem_rule = Rule(TreeTypes.Meristem,
                        lhs = mer -> mod(data(mer).age, graph_data(mer).plastochron) == 0,
                        rhs = mer -> TreeTypes.Node() +
                                     (TreeTypes.Bud(),
                                     TreeTypes.Leaf(biomass = vleaf.biomass,
                                                    length  = vleaf.length,
                                                    width   = vleaf.width)) +
                                     TreeTypes.Internode(biomass = vint.biomass,
                                                         length  = vint.length,
                                                         width   = vint.width) +
                                     TreeTypes.Meristem())
end
````

The bud break probability is now a function of distance to the apical meristem
rather than the number of internodes. An adhoc traversal is used to compute this
length of the main branch a bud belongs to (ignoring the lateral branches).
Compute the probability that a bud breaks as function of distance to the meristem

````julia
function prob_break(bud)
    # We move to parent node in the branch where the bud was created
    node =  parent(bud)
    # Extract the first internode
    child = filter(x -> data(x) isa TreeTypes.Internode, children(node))[1]
    data_child = data(child)
    # We measure the length of the branch until we find the meristem
    distance = 0.0
    while !isa(data_child, TreeTypes.Meristem)
        # If we encounter an internode, store the length and move to the next node
        if data_child isa TreeTypes.Internode
            distance += data_child.length
            child = children(child)[1]
            data_child = data(child)
        # If we encounter a node, extract the next internode
        elseif data_child isa TreeTypes.Node
                child = filter(x -> data(x) isa TreeTypes.Internode, children(child))[1]
                data_child = data(child)
        else
            error("Should be Internode, Node or Meristem")
        end
    end
    # Compute the probability of bud break as function of distance and
    # make stochastic decision
    prob =  min(1.0, distance*graph_data(bud).budbreak)
    return rand() < prob
end

# Branch rule parameterized by initial states of internodes
function create_branch_rule(vint)
    branch_rule = Rule(TreeTypes.Bud,
            lhs = prob_break,
            rhs = bud -> TreeTypes.BudNode() +
                         TreeTypes.Internode(biomass = vint.biomass,
                                             length  = vint.length,
                                             width   = vint.width) +
                         TreeTypes.Meristem())
end
````

### Light interception

As growth is now dependent on intercepted PAR via RUE, we now need to simulate
light interception by the trees. We will use a ray-tracing approach to do so.
The first step is to create a scene with the trees and the light sources. As for
rendering, the scene can be created from the `forest` object by simply calling
`Scene(forest)` that will generate the 3D meshes and connect them to their
optical properties.

However, we also want to add the soil surface as this will affect the light
distribution within the scene due to reflection from the soil surface. This is
similar to the customized scene that we created before for rendering, but now
for the light simulation.

````julia
function create_soil()
    soil = Rectangle(length = 21.0, width = 21.0)
    rotatey!(soil, π/2) ## To put it in the XY plane
    VirtualPlantLab.translate!(soil, Vec(0.0, 10.5, 0.0)) ## Corner at (0,0,0)
    return soil
end
function create_scene(forest)
    # These are the trees
    scene = Scene(vec(forest))
    # Add a soil surface
    soil = create_soil()
    soil_material = Lambertian(τ = 0.0, ρ = 0.21)
    add!(scene, mesh = soil, material = soil_material)
    # Return the scene
    return scene
end
````

Given the scene, we can create the light sources that can approximate the solar
irradiance on a given day, location and time of the day using the functions from
the  package (see package documentation for details). Given the latitude,
day of year and fraction of the day (`f = 0` being sunrise and `f = 1` being sunset),
the function `clear_sky()` computes the direct and diffuse solar radiation assuming
a clear sky. These values may be converted to different wavebands and units using
`waveband_conversion()`. Finally, the collection of light sources approximating
the solar irradiance distribution over the sky hemisphere is constructed with the
function `sky()` (this last step requires the 3D scene as input in order to place
the light sources adequately).

````julia
function create_sky(;scene, lat = 52.0*π/180.0, DOY = 182)
    # Fraction of the day and day length
    fs = collect(0.1:0.1:0.9)
    dec = declination(DOY)
    DL = day_length(lat, dec)*3600
    # Compute solar irradiance
    temp = [clear_sky(lat = lat, DOY = DOY, f = f) for f in fs] # W/m2
    Ig   = getindex.(temp, 1)
    Idir = getindex.(temp, 2)
    Idif = getindex.(temp, 3)
    # Conversion factors to PAR for direct and diffuse irradiance
    f_dir = waveband_conversion(Itype = :direct,  waveband = :PAR, mode = :power)
    f_dif = waveband_conversion(Itype = :diffuse, waveband = :PAR, mode = :power)
    # Actual irradiance per waveband
    Idir_PAR = f_dir.*Idir
    Idif_PAR = f_dif.*Idif
    # Create the dome of diffuse light
    dome = sky(scene,
                  Idir = 0.0, ## No direct solar radiation
                  Idif = sum(Idir_PAR)/10*DL, ## Daily Diffuse solar radiation
                  nrays_dif = 1_000_000, ## Total number of rays for diffuse solar radiation
                  sky_model = StandardSky, ## Angular distribution of solar radiation
                  dome_method = equal_solid_angles, ## Discretization of the sky dome
                  ntheta = 9, ## Number of discretization steps in the zenith angle
                  nphi = 12) ## Number of discretization steps in the azimuth angle
    # Add direct sources for different times of the day
    for I in Idir_PAR
        push!(dome, sky(scene, Idir = I/10*DL, nrays_dir = 100_000, Idif = 0.0)[1])
    end
    return dome
end
````

The 3D scene and the light sources are then combined into a `RayTracer` object,
together with general settings for the ray tracing simulation chosen via `RTSettings()`.
The most important settings refer to the Russian roulette system and the grid
cloner (see section on Ray Tracing for details). The settings for the Russian
roulette system include the number of times a ray will be traced
deterministically (`maxiter`) and the probability that a ray that exceeds `maxiter`
is terminated (`pkill`). The grid cloner is used to approximate an infinite canopy
by replicating the scene in the different directions (`nx` and `ny` being the
number of replicates in each direction along the x and y axes, respectively). It
is also possible to turn on parallelization of the ray tracing simulation by
setting `parallel = true` (currently this uses Julia's builtin multithreading
capabilities).

In addition `RTSettings()`, an acceleration structure and a splitting rule can
be defined when creating the `RayTracer` object (see ray tracing documentation
for details). The acceleration structure allows speeding up the ray tracing
by avoiding testing all rays against all objects in the scene.

````julia
function create_raytracer(scene, sources)
    settings = RTSettings(pkill = 0.9, maxiter = 4, nx = 5, ny = 5, parallel = true)
    RayTracer(scene, sources, settings = settings, acceleration = BVH,
                     rule = SAH{3}(5, 10));
end
````

The actual ray tracing simulation is performed by calling the `trace!()` method
on the ray tracing object. This will trace all rays from all light sources and
update the radiant power absorbed by the different surfaces in the scene inside
the `Material` objects (see `feed!()` above):

````julia
function run_raytracer!(forest; DOY = 182)
    scene   = create_scene(forest)
    sources = create_sky(scene = scene, DOY = DOY)
    rtobj   = create_raytracer(scene, sources)
    trace!(rtobj)
    return nothing
end
````

The total PAR absorbed for each tree is calculated from the material objects of
the different internodes (using `power()` on the `Material` object). Note that
the `power()` function returns three different values, one for each waveband,
but they are added together as RUE is defined for total PAR.

Run the ray tracer, calculate PAR absorbed per tree and add it to the daily
total using general weighted quadrature formula

````julia
function calculate_PAR!(forest;  DOY = 182)
    # Reset PAR absorbed by the tree (at the start of a new day)
    reset_PAR!(forest)
    # Run the ray tracer to compute daily PAR absorption
    run_raytracer!(forest, DOY = DOY)
    # Add up PAR absorbed by each leaf within each tree
    @threads for tree in forest
        for l in get_leaves(tree)
            data(tree).PAR += power(l.material)[1]
        end
    end
    return nothing
end
````

Reset PAR absorbed by the tree (at the start of a new day)

````julia
function reset_PAR!(forest)
    for tree in forest
        data(tree).PAR = 0.0
    end
    return nothing
end
````

### Growth

We need some functions to compute the length and width of a leaf or internode
from its biomass

````julia
function leaf_dims(biomass, vars)
    leaf_biomass = biomass
    leaf_area    = biomass/vars.SLW
    leaf_length  = sqrt(leaf_area*4*vars.LS/pi)
    leaf_width   = leaf_length/vars.LS
    return leaf_length, leaf_width
end

function int_dims(biomass, vars)
    int_biomass = biomass
    int_volume  = biomass/vars.SIW
    int_length  = cbrt(int_volume*4*vars.IS^2/pi)
    int_width   = int_length/vars.IS
    return int_length, int_width
end
````

Each day, the total biomass of the tree is updated using a simple RUE formula
and the increment of biomass is distributed across the organs proportionally to
their relative sink strength (of leaves or internodes).

The sink strength of leaves is modelled with a beta distribution scaled to the
`leaf_expansion` argument that determines the duration of leaf growth, whereas
for the internodes it follows a negative exponential distribution. The `pdf`
function computes the probability density of each distribution which is taken as
proportional to the sink strength (the model is actually source-limited since we
imposed a particular growth rate).

````julia
sink_strength(leaf, vars) = leaf.age > vars.leaf_expansion ? 0.0 :
                            pdf(leaf.sink, leaf.age/vars.leaf_expansion)/100.0
plot(0:1:50, x -> sink_strength(TreeTypes.Leaf(age = x), TreeTypes.treeparams()),
     xlabel = "Age", ylabel = "Sink strength", label = "Leaf")

sink_strength(int) = pdf(int.sink, int.age)
plot!(0:1:50, x -> sink_strength(TreeTypes.Internode(age = x)), label = "Internode")
````

Now we need a function that updates the biomass of the tree, allocates it to the
different organs and updates the dimensions of said organs. For simplicity,
we create the functions `leaves()` and `internodes()` that will apply the queries
to the tree required to extract said nodes:

````julia
get_leaves(tree) = apply(tree, Query(TreeTypes.Leaf))
get_internodes(tree) = apply(tree, Query(TreeTypes.Internode))
````

The age of the different organs is updated every time step:

````julia
function age!(all_leaves, all_internodes, all_meristems)
    for leaf in all_leaves
        leaf.age += 1
    end
    for int in all_internodes
        int.age += 1
    end
    for mer in all_meristems
        mer.age += 1
    end
    return nothing
end
````

The daily growth is allocated to different organs proportional to their sink
strength.

````julia
function grow!(tree, all_leaves, all_internodes)
    # Compute total biomass increment
    tdata = data(tree)
    ΔB    = max(0.5, tdata.RUE*tdata.PAR/1e6) # Trick to emulate reserves in seedling
    tdata.biomass += ΔB
    # Total sink strength
    total_sink = 0.0
    for leaf in all_leaves
        total_sink += sink_strength(leaf, tdata)
    end
    for int in all_internodes
        total_sink += sink_strength(int)
    end
    # Allocate biomass to leaves and internodes
    for leaf in all_leaves
        leaf.biomass += ΔB*sink_strength(leaf, tdata)/total_sink
    end
    for int in all_internodes
        int.biomass += ΔB*sink_strength(int)/total_sink
    end
    return nothing
end
````

Finally, we need to update the dimensions of the organs. The leaf dimensions are

````julia
function size_leaves!(all_leaves, tvars)
    for leaf in all_leaves
        leaf.length, leaf.width = leaf_dims(leaf.biomass, tvars)
    end
    return nothing
end
function size_internodes!(all_internodes, tvars)
    for int in all_internodes
        int.length, int.width = int_dims(int.biomass, tvars)
    end
    return nothing
end
````

### Daily step

All the growth and developmental functions are combined together into a daily
step function that updates the forest by iterating over the different trees in
parallel.

````julia
get_meristems(tree) = apply(tree, Query(TreeTypes.Meristem))
function daily_step!(forest, DOY)
    # Compute PAR absorbed by each tree
    calculate_PAR!(forest, DOY = DOY)
    # Grow the trees
    @threads for tree in forest
        # Retrieve all the relevant organs
        all_leaves = get_leaves(tree)
        all_internodes = get_internodes(tree)
        all_meristems = get_meristems(tree)
        # Update the age of the organs
        age!(all_leaves, all_internodes, all_meristems)
        # Grow the tree
        grow!(tree, all_leaves, all_internodes)
        tdata = data(tree)
        size_leaves!(all_leaves, tdata)
        size_internodes!(all_internodes, tdata)
        # Developmental rules
        rewrite!(tree)
    end
end
````

### Initialization

The trees are initialized on a regular grid with random values for the initial
orientation and RUE:

````julia
RUEs = rand(Normal(1.5,0.2), 10, 10)
histogram(vec(RUEs))

orientations = [rand()*360.0 for i = 1:2.0:20.0, j = 1:2.0:20.0]
histogram(vec(orientations))

origins = [Vec(i,j,0) for i = 1:2.0:20.0, j = 1:2.0:20.0];
````

The following initalizes a tree based on the origin, orientation and RUE:

````julia
function create_tree(origin, orientation, RUE)
    # Initial state and parameters of the tree
    data = TreeTypes.treeparams(RUE = RUE)
    # Initial states of the leaves
    leaf_length, leaf_width = leaf_dims(data.LB0, data)
    vleaf = (biomass = data.LB0, length = leaf_length, width = leaf_width)
    # Initial states of the internodes
    int_length, int_width = int_dims(data.LB0, data)
    vint = (biomass = data.IB0, length = int_length, width = int_width)
    # Growth rules
    meristem_rule = create_meristem_rule(vleaf, vint)
    branch_rule   = create_branch_rule(vint)
    axiom = T(origin) + RH(orientation) +
            TreeTypes.Internode(biomass = vint.biomass,
                                length  = vint.length,
                                width   = vint.width) +
            TreeTypes.Meristem()
    tree = Graph(axiom = axiom, rules = (meristem_rule, branch_rule),
                 data = data)
    return tree
end
````

## Visualization

As in the previous example, it makes sense to visualize the forest with a soil
tile beneath it. Unlike in the previous example, we will construct the soil tile
using a dedicated graph and generate a `Scene` object which can later be
merged with the rest of scene generated in daily step:

````julia
Base.@kwdef struct Soil <: VirtualPlantLab.Node
    length::Float64
    width::Float64
end
function VirtualPlantLab.feed!(turtle::Turtle, s::Soil, data)
    Rectangle!(turtle, length = s.length, width = s.width, color = RGB(255/255, 236/255, 179/255))
end
soil_graph = RA(-90.0) + T(Vec(0.0, 10.0, 0.0)) + ## Moves into position
             Soil(length = 20.0, width = 20.0) ## Draws the soil tile
soil = Scene(Graph(axiom = soil_graph));
render(soil, axes = false)
````

And the following function renders the entire scene (notice that we need to
use `display()` to force the rendering of the scene when called within a loop
or a function):

````julia
function render_forest(forest, soil)
    scene = Scene(vec(forest)) ## create scene from forest
    scene = Scene([scene, soil]) ## merges the two scenes
    display(render(scene))
end
````

## Simulation

We can now create a forest of trees on a regular grid:

````julia
forest = create_tree.(origins, orientations, RUEs);
render_forest(forest, soil)
start = 180
for i in 1:20
    println("Day $i")
    daily_step!(forest, i + start)
    if mod(i, 5) == 0
        render_forest(forest, soil)
    end
end
````

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*



# Relational queries

Alejandro Morales

Centre for Crop Systems Analysis - Wageningen University

In this example we illustrate how to test relationships among nodes inside queries.
Relational queries allow to establish relationships between nodes in the graph,
which generally requires a intimiate knowledge of the graph. For this reason,
relational queries are inheretly complex as graphs can become complex and there
may be solutions that do not require relational queries in many instances.
Nevertheless, they are integral part of VPL and can sometimes be useful. As they
can be hard to grasp, this tutorial will illustrate with a relatively simple
graph a series of relational queries with increasing complexity with the aim
that users will get a better understanding of relational queries. For this purpose,
an abstract graph with several branching levels will be used, so that we can focus
on the relations among the nodes without being distracted by case-specific details.

The graph will be composed of two types of nodes: the inner nodes (`A` and `C`) and the
leaf nodes (`B`). Each leaf node will be identified uniquely with an index and
the objective is to write queries that can identify a specific subset of the leaf
nodes, without using the data stored in the nodes themselves. That is, the queries
should select the right nodes based on their relationships to the rest of nodes
in the graph. Note that `C` nodes contain a single value that may be positive or negative,
whereas `A` nodes contain no data.

As usual, we start with defining the types of nodes in the graph

````julia
using VirtualPlantLab
import GLMakie

module Queries
    using VirtualPlantLab
    struct A <: Node end

    struct C <: Node
        val::Float64
    end

    struct B <: Node
        ID::Int
    end
end
import .Queries as Q
````

We generate the graph directly, rather than with rewriting rules. The graph has
a motif that is repeated three times (with a small variation), so we can create
the graph in a piecewise manner. Note how we can use the function `sum` to add
nodes to the graph (i.e. `sum(A() for i in 1:3)` is equivalent to `A() + A() + A()`)

````julia
motif(n, i = 0) = Q.A() + (Q.C(45.0) + Q.A() + (Q.C(45.0) +  Q.A() + Q.B(i + 1),
                                           Q.C(-45.0) + Q.A() + Q.B(i + 2),
                                                       Q.A() + Q.B(i + 3)),
                         Q.C(- 45.0) + sum(Q.A() for i in 1:n) + Q.B(i + 4))
axiom =  motif(3, 0) + motif(2, 4) + motif(1, 8) + Q.A() + Q.A() + Q.B(13)
graph = Graph(axiom = axiom);
draw(graph)
````

By default, VPL will use as node label the type of node and the internal ID generated by VPL itself. This ID is useful if we want to
extract a particular node from the graph, but it is not controlled by the user. However, the user can specialized the function `node_label()`
to specify exactly how to label the nodes of a particular type. In this case, we want to just print `A` or `C` for nodes of type `A` and `C`, whereas
for nodes of type `B` we want to use the `ID` field that was stored inside the node during the graph generation.

````julia
VirtualPlantLab.node_label(n::Q.B, id) = "B-$(n.ID)"
VirtualPlantLab.node_label(n::Q.A, id) = "A"
VirtualPlantLab.node_label(n::Q.C, id) = "C"
draw(graph)
````

To clarify, the `id` argument of the function `node_label()` refers to the internal id generated by VPL (used by the default method for `node_label()`, whereas the the first argument is the data stored inside a node (in the case of `B` nodes, there is a field called `ID` that will not be modified by VPL as that is user-provided data).

The goal of this exercise is then to write queries that retrieve specific `B`
nodes  without using the data stored in the node in the query. That is, we have
to identify nodes based on their relationships to other nodes.

## All nodes of type `B`

First, we create the query object. In this case, there is no special condition as
we want to retrieve all the nodes of type `B`

````julia
Q1 = Query(Q.B)
````

Applying the query to the graph returns an array with all the `B` nodes

````julia
A1 = apply(graph, Q1)
````

For the remainder of this tutorial, the code will be hidden by default to allow users to try on their own.


## Node containing value 13

Since the `B` node 13 is the leaf node of the main branch of the graph (e.g. this could be the apical meristem of the main stem of a plant), there
are no rotations between the root node of the graph and this node. Therefore,
the only condition require to single out this node is that it has no ancestor
node of type `C`.

Checking whether a node has an ancestor that meets a certain
condition can be achieved with the function `hasAncestor()`. Similarly to the
condition of the `Query` object, the `hasAncestor()` function also has a condition,
in this case applied to the parent node of the node being tested, and moving
upwards in the graph recursively (until reaching the root node). Note that, in
order to access the object stored inside the node, we need to use the `data()`
function, and then we can test if that object is of type `C`. The `B` node 13
is the only node for which `hasAncestor()` should return `false`:

````julia
function Q2_fun(n)
    check, steps = has_ancestor(n, condition = x -> data(x) isa Q.C)
    !check
end
````

As before, we just need to apply the `Query` object to the graph:

````julia
Q2 = Query(Q.B, condition = Q2_fun)
A2 = apply(graph, Q2)
````

## Nodes containing values 1, 2 and 3

These three nodes belong to one of the branch motifs repeated through the graph. Thus,
we need to identify the specific motif they belong to and chose all the `B` nodes
inside that motif. The motif is defined by an `A` node that has a `C` child with
a negative `val` and parent node `C` with positive `val`. This `A` node
should then be 2 nodes away from the root node to separate it from upper repetitions
of the motif.
Therefore, we need to test for two conditions, first find those nodes inside a
branch motif, then retrieve the root of the branch motif (i.e., the `A` node
described in the above) and then check the distance of that node from the root:

````julia
function branch_motif(p)
    data(p) isa Q.A &&
    has_descendant(p, condition = x -> data(x) isa Q.C && data(x).val < 0.0)[1] &&
    has_ancestor(p, condition = x -> data(x) isa Q.C && data(x).val > 0.0)[1]
end

function Q3_fun(n, nsteps)
    # Condition 1
    check, steps = has_ancestor(n, condition = branch_motif)
    !check && return false
    # Condition 2
    p = parent(n, nsteps = steps)
    check, steps = has_ancestor(p, condition = is_root)
    steps != nsteps && return false
    return true
end
````

And applying the query to the object results in the required nodes:

````julia
Q3 = Query(Q.B, condition = n -> Q3_fun(n, 2))
A3 = apply(graph, Q3)
````

## Node containing value 4

The node `B` with value 4 can be singled-out because there is no branching point
between the root node and this node. This means that no ancestor node should have
more than one children node except the root node. Remember that `hasAncestor()`
returns two values, but we are only interested in the first value. You do not need to
assign the returned object from a Julia function, you can just index directly the element
to be selected from the returned tuple:

````julia
function Q4_fun(n)
    !has_ancestor(n, condition = x -> is_root(x) && length(children(x)) > 1)[1]
end
````

And applying the query to the object results in the required node:

````julia
Q4 = Query(Q.B, condition = Q4_fun)
A4 = apply(graph, Q4)
````

## Node containing value 3

This node is the only `B` node that is four steps from the root node, which we can
retrieve from the second argument returned by `hasAncestor()`:

````julia
function Q5_fun(n)
    check, steps = has_ancestor(n, condition = is_root)
    steps == 4
end

Q5 = Query(Q.B, condition = Q5_fun)
A5 = apply(graph, Q5)
````

## Node containing value 7

Node `B` 7 belongs to the second lateral branch motif and the second parent
node is of type `A`. Note that we can reuse the `Q3_fun` from before in the
condition required for this node:

````julia
function Q6_fun(n, nA)
    check = Q3_fun(n, nA)
    !check && return false
    p2 = parent(n, nsteps = 2)
    data(p2) isa Q.A
end

Q6 = Query(Q.B, condition = n -> Q6_fun(n, 3))
A6 = apply(graph, Q6)
````

## Nodes containing values 11 and 13

The `B` nodes 11 and 13 actually have different relationships to the rest of the graph,
so we just need to define two different condition functions and combine them.
The condition for the `B` node 11 is similar to the `B` node 7, whereas the condition
for node 13 was already constructed before, so we just need to combined them with an
OR operator:

````julia
Q7 = Query(Q.B, condition = n -> Q6_fun(n, 4) || Q2_fun(n))
A7 = apply(graph, Q7)
````

## Nodes containing values 1, 5 and 9

These nodes play the same role in the three lateral branch motifs. They are the
only `B` nodes preceded by the sequence A C+ A. We just need to check the
sequence og types of objects for the the first three parents of each `B` node:

````julia
function Q8_fun(n)
    p1 = parent(n)
    p2 = parent(n, nsteps = 2)
    p3 = parent(n, nsteps = 3)
    data(p1) isa Q.A && data(p2) isa Q.C && data(p2).val > 0.0 && data(p3) isa Q.A
end

Q8 = Query(Q.B, condition = Q8_fun)
A8 = apply(graph, Q8)
````

## Nodes contaning values 2, 6 and 10

This exercise is similar to the previous one, but the C node has a negative
`val`. The problem is that node 12 would also match the pattern A C- A. We
can differentiate between this node and the rest by checking for a fourth
ancestor node of class `C`:

````julia
function Q9_fun(n)
    p1 = parent(n)
    p2 = parent(n, nsteps = 2)
    p3 = parent(n, nsteps = 3)
    p4 = parent(n, nsteps = 4)
    data(p1) isa Q.A && data(p2) isa Q.C && data(p2).val < 0.0 &&
       data(p3) isa Q.A && data(p4) isa Q.C
end

Q9 = Query(Q.B, condition = Q9_fun)
A9 = apply(graph, Q9)
````

## Nodes containg values 6, 7 and 8

We already came up with a condition to extract node 7. We can also modify the previous
condition so that it only node 6.  Node 8 can be identified by checking for the third
parent node being of type `C` and being 5 nodes from the root of the graph.

As always, we can reusing previous conditions since they are just regular Julia functions:

````julia
function Q10_fun(n)
    Q6_fun(n, 3) && return true ## Check node 7
    Q9_fun(n) && has_ancestor(n, condition = is_root)[2] == 6 && return true ## Check node 6
    has_ancestor(n, condition = is_root)[2] == 5 && data(parent(n, nsteps = 3)) isa Q.C && return true ## Check node 8 (and not 4!)
end

Q10 = Query(Q.B, condition = Q10_fun)
A10 = apply(graph, Q10)
````

## Nodes containig values 3, 7, 11 and 12

We already have conditions to select nodes 3, 7 and 11 so we just need a new condition
for node 12 (similar to the condition for 8).

````julia
function Q11_fun(n)
    Q5_fun(n) && return true ## 3
    Q6_fun(n, 3) && return true ## 7
    Q6_fun(n, 4) && return true ## 11
    has_ancestor(n, condition = is_root)[2] == 5 && data(parent(n, nsteps = 2)) isa Q.C &&
        data(parent(n, nsteps = 4)) isa Q.A && return true ## 12
end

Q11 = Query(Q.B, condition = Q11_fun)
A11 = apply(graph, Q11)
````

## Nodes containing values 7 and 12

We just need to combine the conditions for the nodes 7 and 12

````julia
function Q12_fun(n)
    Q6_fun(n, 3) && return true # 7
    has_ancestor(n, condition = is_root)[2] == 5 && data(parent(n, nsteps = 2)) isa Q.C &&
        data(parent(n, nsteps = 4)) isa Q.A && return true ## 12
end

Q12 = Query(Q.B, condition = Q12_fun)
A12 = apply(graph, Q12)
````

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*



# The Koch snowflake

Alejandro Morales

Centre for Crop Systems Analysis - Wageningen University


In this example, we create a Koch snowflake, which is one of the earliest
fractals to be described. The Koch snowflake is a closed curve composed on
multiple of segments of different lengths. Starting with an equilateral
triangle, each segment in the snowflake is replaced by four segments of smaller
length arrange in a specific manner. Graphically, the first four iterations of
the Koch snowflake construction process result in the following figures (the
green segments are shown as guides but they are not part of the snowflake):

![First four iterations fo Koch snowflake fractal](https://upload.wikimedia.org/wikipedia/commons/8/8e/KochFlake.png)

In order to implement the construction process of a Koch snowflake in VPL we
need to understand how a 3D structure can be generated from a graph of nodes.
VPL uses a procedural approach to generate of structure based on the concept of
turtle graphics.

The idea behind this approach is to imagine a turtle located in space with a
particular position and orientation. The turtle then starts consuming the
different nodes in the graph (following its topological structure) and generates
3D structures as defined by the user for each type of node. The consumption of a
node may also include instructions to move and/or rotate the turtle, which
allows to alter the relative position of the different 3D structures described
by a graph.

The construction process of the Koch snowflake in VPL could then be represented
by the following axiom and rewriting rule:

axiom: E(L) + RU(120) + E(L) + RU(120) + E(L)
rule:  E(L) → E(L/3) + RU(-60) + E(L/3) + RU(120) + E(L/3) + RU(-60) + E(L/3)

Where E represent and edge of a given length (given in parenthesis) and RU
represents a rotation of the turtle around the upward axis, with angle of
rotation given in parenthesis in hexadecimal degrees. The rule can be visualized
as follows:

![Koch construction rule](https://python-with-science.readthedocs.io/en/latest/_images/koch_order_1.png)

Note that VPL already provides several classes for common turtle movements and
rotations, so our implementation of the Koch snowflake only needs to define a
class to implement the edges of the snowflake. This can be achieved as follows:

````julia
using VirtualPlantLab
import GLMakie ## Import rather than "using" to avoid masking Scene
using ColorTypes ## To define colors for the rendering
module sn
    import VirtualPlantLab
    struct E <: VirtualPlantLab.Node
        length::Float64
    end
end
import .sn
````

Note that nodes of type E need to keep track of the length as illustrated in the
above. The axiom is straightforward:

````julia
const L = 1.0
axiom = sn.E(L) + VirtualPlantLab.RU(120.0) + sn.E(L) + VirtualPlantLab.RU(120.0) + sn.E(L)
````

The rule is also straightforward to implement as all the nodes of type E will be
replaced in each iteration. However, we need to ensure that the length of the
new edges is a calculated from the length of the edge being replaced. In order
to extract the data stored in the node being replaced we can simply use the
function data. In this case, the replacement function is defined and then added
to the rule. This can make the code more readable but helps debugging and
testing the replacement function.

````julia
function Kochsnowflake(x)
    L = data(x).length
    sn.E(L/3) + RU(-60.0) + sn.E(L/3) + RU(120.0) + sn.E(L/3) + RU(-60.0) + sn.E(L/3)
end
rule = Rule(sn.E, rhs = Kochsnowflake)
````

The model is then created by constructing the graph

````julia
Koch = Graph(axiom = axiom, rules = Tuple(rule))
````

In order to be able to generate a 3D structure we need to define a method for
the function `VirtualPlantLab.feed!` (notice the need to prefix it with `VirtualPlantLab.` as we are
going to define a method for this function). The method needs to two take two
arguments, the first one is always an object of type Turtle and the second is an
object of the type for which the method is defined (in this case, E).

The body of the method should generate the 3D structures using the geometry
primitives provided by VPL and feed them to the turtle that is being passed to
the method as first argument. In this case, we are going to represent the edges
of the Koch snowflakes with cylinders, which can be generated with the
`HollowCylinder!` function from VirtualPlantLab. Note that the `feed!` should return
`nothing`, the turtle will be modified in place (hence the use of `!` at the end
of the function as customary in the VPL community).

In order to render the geometry, we need assign a `color` (i.e., any type of
color support by the package ColorTypes.jl). In this case, we just feed a basic
`RGB` color defined by the proportion of red, green and blue. To make the
figures more appealing, we can assign random values to each channel of the color
to generate random colors.

````julia
function VirtualPlantLab.feed!(turtle::Turtle, e::sn.E, vars)
    HollowCylinder!(turtle, length = e.length, width = e.length/10,
                    height = e.length/10, move = true,
                    color = RGB(rand(), rand(), rand()))
    return nothing
end
````

Note that the argument `move = true` indicates that the turtle should move
forward as the cylinder is generated a distance equal to the length of the
cylinder. Also, the `feed!` method has a third argument called `vars`. This
gives acess to the shared variables stored within the graph (such that they can
be accessed by any node). In this case, we are not using this argument.

After defining the method, we can now call the function render on the graph to
generate a 3D interactive image of the Koch snowflake in the current state

````julia
sc = Scene(Koch)
render(sc, axes = false)
````

This renders the initial triangle of the construction procedure of the Koch
snowflake. Let's execute the rules once to verify that we get the 2nd iteration
(check the figure at the beginning of this document):

````julia
rewrite!(Koch)
render(Scene(Koch), axes = false)
````

And two more times

````julia
for i in 1:3
    rewrite!(Koch)
end
render(Scene(Koch), axes = false)
````

# Other snowflake fractals

To demonstrate the power of this approach, let's create an alternative
snowflake. We will simply invert the rotations of the turtle in the rewriting
rule

````julia
function Kochsnowflake2(x)
   L = data(x).length
   sn.E(L/3) + RU(60.0) + sn.E(L/3) + RU(-120.0) + sn.E(L/3) + RU(60.0) + sn.E(L/3)
end
rule2 = Rule(sn.E, rhs = Kochsnowflake2)
Koch2 = Graph(axiom = axiom, rules = Tuple(rule2))
````

The axiom is the same, but now the edges added by the rule will generate the
edges towards the inside of the initial triangle. Let's execute the first three
iterations and render the results

````julia
# First iteration
rewrite!(Koch2)
render(Scene(Koch2), axes = false)
# Second iteration
rewrite!(Koch2)
render(Scene(Koch2), axes = false)
# Third iteration
rewrite!(Koch2)
render(Scene(Koch2), axes = false)
````

This is know as [Koch
antisnowflake](https://mathworld.wolfram.com/KochAntisnowflake.html). We could
also easily generate a [Cesàro
fractal](https://mathworld.wolfram.com/CesaroFractal.html) by also changing the
axiom:

````julia
axiomCesaro = sn.E(L) + RU(90.0) + sn.E(L) + RU(90.0) + sn.E(L) + RU(90.0) + sn.E(L)
Cesaro = Graph(axiom = axiomCesaro, rules = (rule2,))
render(Scene(Cesaro), axes = false)
````

And, as before, let's go through the first three iterations

````julia
# First iteration
rewrite!(Cesaro)
render(Scene(Cesaro), axes = false)
# Second iteration
rewrite!(Cesaro)
render(Scene(Cesaro), axes = false)
# Third iteration
rewrite!(Cesaro)
render(Scene(Cesaro), axes = false)
````

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*



# Tree

Alejandro Morales

Centre for Crop Systems Analysis - Wageningen University


In this example we build a 3D representation of a binary TreeTypes. Although this will not look like a real plant, this example will help introduce additional features of VPL.

The model requires five types of nodes:

*Meristem*: These are the nodes responsible for growth of new organs in our binary TreeTypes. They contain no data or geometry (i.e. they are a point in the 3D structure).

*Internode*: The result of growth of a branch, between two nodes. Internodes are represented by cylinders with a fixed width but variable length.

*Node*: What is left after a meristem produces a new organ (it separates internodes). They contain no data or geometry (so also a point) but are required to keep the branching structure of the tree as well as connecting leaves.

*Bud*: These are dormant meristems associated to tree nodes. When they are activated, they become an active meristem that produces a branch. They contain no data or geometry but they change the orientation of the turtle.

*BudNode*: The node left by a bud after it has been activated. They contain no data or geometry but they change the orientation of the turtle.

*Leaf*: These are the nodes associated to leaves in the TreeTypes. They are represented by ellipses with a particular orientation and insertion angle. The insertion angle is assumed constant, but the orientation angle varies according to an elliptical phyllotaxis rule.

In this first simple model, only internodes grow over time according to a relative growth rate, whereas leaves are assumed to be of fixed sized determined at their creation. For simplicity, all active meristems will produce an phytomer (combination of node, internode, leaves and buds) per time step. Bud break is assumed stochastic, with a probability that increases proportional to the number of phytomers from the apical meristem (up to 1). In the following tutorials, these assumptions are replaced by more realistic models of light interception, photosynthesis, etc.

In order to simulate growth of the 3D binary tree, we need to define a parameter describing the relative rate at which each internode elongates in each iteration of the simulation, a coefficient to compute the probability of bud break as well as the insertion and orientation angles of the leaves. We could stored these values as global constants, but VPL offers to opportunity to store them per plant. This makes it easier to manage multiple plants in the same simulation that may belong to different species, cultivars, ecotypes or simply to simulate plant-to-plant variation. Graphs in VPL can store an object of any user-defined type that will me made accessible to graph rewriting rules and queries. For this example, we define a data type `treeparams` that holds the relevant parameters. We use `Base.@kwdef` to assign default values to all parameters and allow to assign them by name.

````julia
using VirtualPlantLab
using ColorTypes
import GLMakie

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
        length::Float64 = 0.20 ## Leaves are 20 cm long
        width::Float64  = 0.1 ## Leaves are 10 cm wide
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
````

As always, the 3D structure and the color of each type of node are implemented with the `feed!` method. In this case, the internodes and leaves have a 3D representation, whereas bud nodes rotate the turtle. The rest of the elements of the trees are just points in the 3D structure, and hence do not have an explicit geometry:

````julia
# Create geometry + color for the internodes
function VirtualPlantLab.feed!(turtle::Turtle, i::TreeTypes.Internode, vars)
    # Rotate turtle around the head to implement elliptical phyllotaxis
    rh!(turtle, vars.phyllotaxis)
    HollowCylinder!(turtle, length = i.length, height = i.length/15, width = i.length/15,
                move = true, color = RGB(0.5,0.4,0.0))
    return nothing
end

# Create geometry + color for the leaves
function VirtualPlantLab.feed!(turtle::Turtle, l::TreeTypes.Leaf, vars)
    # Rotate turtle around the arm for insertion angle
    ra!(turtle, -vars.leaf_angle)
    # Generate the leaf
    Ellipse!(turtle, length = l.length, width = l.width, move = false,
             color = RGB(0.2,0.6,0.2))
    # Rotate turtle back to original direction
    ra!(turtle, vars.leaf_angle)
    return nothing
end

# Insertion angle for the bud nodes
function VirtualPlantLab.feed!(turtle::Turtle, b::TreeTypes.BudNode, vars)
    # Rotate turtle around the arm for insertion angle
    ra!(turtle, -vars.branch_angle)
end
````

The growth rule for a branch within a tree is simple: a phytomer (or basic unit of morphology) is composed of a node, a leaf, a bud node, an internode and an active meristem at the end. Each time step, the meristem is replaced by a new phytomer, allowing for developmemnt within a branch.

````julia
meristem_rule = Rule(TreeTypes.Meristem, rhs = mer -> TreeTypes.Node() +
                                              (TreeTypes.Bud(), TreeTypes.Leaf()) +
                                         TreeTypes.Internode() + TreeTypes.Meristem())
````

In addition, every step of the simulation, each bud may break, creating a new branch. The probability of bud break is proportional to the number of phytomers from the apical meristem (up to 1), which requires a relational rule to count the number of internodes in the graph up to reaching a meristem. When a bud breaks, it is replaced by a bud node, an internode and a new meristem. This new meristem becomes the apical meristem of the new branch, such that `meristem_rule` would apply. Note how we create an external function to compute whether a bud breaks or not. This is useful to keep the `branch_rule` rule simple and readable, while allow for a relatively complex bud break model. It also makes it easier to debug the bud break model, since it can be tested independently of the graph rewriting.

````julia
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
````

A binary tree initializes as an internode followed by a meristem, so the axiom can be constructed simply as:

````julia
axiom = TreeTypes.Internode() + TreeTypes.Meristem()
````

And the object for the tree can be constructed as in previous examples, by passing the axiom and the graph rewriting rules, but in this case also with the object with growth-related parameters.

````julia
tree = Graph(axiom = axiom, rules = (meristem_rule, branch_rule), data = TreeTypes.treeparams())
````

Note that so far we have not included any code to simulate growth of the internodes. The reason is that, as elongation of internotes does not change the topology of the graph (it simply changes the data stored in certain nodes), this process does not need to be implemented with graph rewriting rules. Instead, we will use a combination of a query (to identify which nodes need to be altered) and direct modification of these nodes:

````julia
getInternode = Query(TreeTypes.Internode)
````

If we apply the query to a graph using the `apply` function, we will get an array of all the nodes that match the query, allow for direct manipulation of their contents. To help organize the code, we will create a function that simulates growth by multiplying the `length` argument of all internodes in a tree by the `growth` parameter defined in the above:

````julia
function elongate!(tree, query)
    for x in apply(tree, query)
        x.length = x.length*(1.0 + data(tree).growth)
    end
end
````

Note that we use `vars` on the `Graph` object to extract the object that was stored inside of it. Also, as this function will modify the graph which is passed as input, we append an `!` to the name (this not a special syntax of the language, its just a convention in the Julia community). Also, in this case, the query object is kept separate from the graph. We could have also stored it inside the graph like we did for the parameter `growth`. We could also have packaged the graph and the query into another type representing an individual TreeTypes. This is entirely up to the user and indicates that a model can be implemented in many differences ways with VPL.

Simulating the growth a tree is a matter of elongating the internodes and applying the rules to create new internodes:

````julia
function growth!(tree, query)
    elongate!(tree, query)
    rewrite!(tree)
end
````

and a simulation for n steps is achieved with a simple loop:

````julia
function simulate(tree, query, nsteps)
    new_tree = deepcopy(tree)
    for i in 1:nsteps
        growth!(new_tree, query)
    end
    return new_tree
end
````

Notice that the `simulate` function creates a copy of the object to avoid overwriting it. If we run the simulation for a couple of steps

````julia
newtree = simulate(tree, getInternode, 2)
````

The binary tree after two iterations has two branches, as expected:

````julia
render(Scene(newtree))
````

Notice how the lengths of the prisms representing internodes decreases as the branching order increases, as the internodes are younger (i.e. were generated fewer generations ago). Further steps will generate a structure that is more tree-like.

````julia
newtree = simulate(newtree, getInternode, 15)
render(Scene(newtree))
````

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*
