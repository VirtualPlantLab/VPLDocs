
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
