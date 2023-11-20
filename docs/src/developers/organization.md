#  [Organization of VPL](@id organization)

In terms of implementation, VPL consists of a GitHub organization ([VirtualPlantLab](https://github.com/VirtualPlantLab/VirtualPlantLab.jl))
that contains 9 registered Julia packages. The packages are organized in two groups:

- The *VPL core*: These are the basic packages that provide the functionality to build FSP models. The user is normally not intended to use these packages directly but rather through the interface offered by [VirtualPlantLab.jl](https://github.com/VirtualPlantLab/VirtualPlantLab.jl). Developers who want to access the source code (and potentially modify it) should first identify the package that contains the functionality they are interested in.

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
