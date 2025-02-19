**Redo tutorial using a tiled floor, we should be able to see spatial distribution better**


# Constructing light sources

Alejandro Morales

Centre for Crop Systems Analysis - Wageningen University

## What makes a light source?

In VPL, a light (or radiation) source is responsible for generating rays that will be
traced throughout a 3D scene as they interact with surfaces. A ray is composed of three
components: a direction, an origin, and a vector of radiant power.

Both the origin and the direction of a ray are generated randomly by the light source
according to specific distributions, whereas the radiant power per ray and the total number
of rays is determined by the user during the simulation. Therefore, defining a new type of
light source consists of defining the distributions for the origin and direction of the rays.

The origin of the rain is determined by the geometry component of a light source (field
`geom` of the type `Source`). VPL currently supports the following geometry components:

- `PointSource`: A single point in space from which all rays are generated.

- `LineSource`: A line segment in space from which all rays are sampled randomly.

- `AreaSource`: A 3D mesh representing a surface from which all rays are sampled randomly.

- `DirectionalSource`: A special case for directional light sources that should cover the entire scene (assuming one is using a grid cloner).

The direction of the rays is determined by the direction component of a light source (field
`angle` of the type `Source`). VPL currently implements two types of direction components:

- `FixedSource`: All rays have the same direction (generally combined with `DirectionalSource` to represent solar radiation).

- `LambertianSource`: The direction of the rays is sampled from a Lambertian distribution.

Users may want to defined their own light sources, often by specifying different distributions
of directions to the ones provided by VPL in order to capture more realistic the light
sources used in certain productive contexts (e.g., greenhouses and vertical farms). This
guide illustrates how to define a new light source in VPL by specifying the direction
component assuming a Gaussian distribution.

## Creating your own direction component of a light source

Creating a new direction component in VPL is straightforward. The user needs to define a
new type that inherits from the abstract class `SourceAngle` and defined a method for the
function `generate_direction` that takes as first argument the user-defined type and as
second a random number generator. The method should return a 3D unit vector representing the
direction of the ray. The user is given complete freedom as to how the direction is
generated.

Typically, the distribution of possible distributions is encoded in polar coordinates, that
is, the azimuth ($Phi$, orientation of the ray) and zenith angles ($theta$, inclination of
the ray) with respect to the plane that contains the light source. This requires defining a
local coordinate system for the light source, that is, an XYZ coordinate system where the XY
plane is the plane that contains the light source and the Z axis is perpendicular to the
plane.

Given the azimuth and zenith angles and the local coordinate system, the direction of the
ray can be computed using the `polar_to_cartesian` function provided by the package
PlantRayTracer within VPL.

The function `polar_to_cartesian` will perform the necessary conversions and ensure that the
resulting direction vector meets the expectations of the ray tracer within VPL. The user
thus only needs to specify distributions for the azimuth and zenith angles and generate the
samples accordingly. Let's illustrate this with a Gaussian light source.

## Example: Gaussian light source

A Gaussian light source is a light source where the azimuth angle follows an uniform
distribution (from 0 to 2π radians) and the zenith angle follows a Gaussian distribution
constrained within the interval [-π/2, π/2] radians centered at 0. This Gaussian distribution
will be parameterized by a standard deviation $\sigma$. First we define the type for the
Gaussian light source to store the axes of the local coordinate system and the standard
deviation of the zenith angle.

```julia
using VirtualPlantLab
import PlantRayTracer as PRT
struct GaussianSource <: PRT.SourceAngle
    x::Vec{Float64}
    y::Vec{Float64}
    z::Vec{Float64}
    σ::Float64
end
```

We will then use the Distributions.jl package to generate the samples for the zenith angle by
defining a method to the function `generate_direction`:

```julia
using Distributions
import ColorTypes: RGB
function PRT.generate_direction(source::GaussianSource, rng)
    dist = Truncated(Normal(0, source.σ), -π/2, π/2)
    θ    = rand(rng, dist)
    Φ    = 2π*rand(rng)
    dir  = PRT.polar_to_cartesian((e1 = source.x, e2 = source.y, n = source.z), θ, Φ)
    return dir
end
```

We also need to define the geometry of the light source. Let's assume that the light source
is just a point in space at coordinates [0.5, 0.5, 1.0], that it is pointing downwards, the
radiant power is 1 and we want to generate one million rays. We create the light source as
follows:

```julia
source = Source(PointSource(Vec(0.5, 0.5, 1.0)), GaussianSource(X(), Y(), -Z(), 0.1), 1.0, 1_000_000)
```

This light source is rather narrow as we use a standar deviation of 0.1. We can visualize the
distribution of zenith angles as follows:

```julia
using Plots
dist = Truncated(Normal(0, 0.1), -π/2, π/2)
θ = rand(dist, 1_000_000)
histogram(θ, label = "", xlabel = "Zenith angle", ylabel = "Prob. density", normalize=:pdf)
vline!([-π/2, π/2], label = "")
```

The light source is now ready to be used in a ray tracer. We will test this light source by
creating multiple sensors below the light source and measuring the light intensity at each
sensor.

```julia
mesh = Mesh()
sensors = [Sensor(1) for _ in 1:400]
c = 1
for i in 1:20
    for j in 1:20
        r = Rectangle(length = 0.05, width = 0.05)
        rotatey!(r, π/2) ## To put it in the XY plane
        VirtualPlantLab.translate!(r, Vec((i - 1)*0.05, (j - 1)*0.05 + 0.025, 0.0))
        add!(mesh, r, materials = sensors[c], colors = rand(RGB))
        c += 1
    end
end
```

```julia
import GLMakie
render(mesh)
```

We can now create a ray tracing object without a grid cloner (note that since all the
surfaces are sensors we can just set `maxiter = 1`):

```julia
settings = RTSettings(pkill = 0.9, maxiter = 1, parallel = true)
rtobj = RayTracer(mesh, source, settings = settings);
trace!(rtobj)
```

We can now visualize the results by plotting the light intensity at each sensor:

```julia
p_narrow = [power(s)[1]/1_000_000 for s in sensors]
coords = collect(0.025:0.05:0.975)
heatmap(coords, coords, reshape(p_narrow,20,20))
```

We can see a straight line meaning that the light intensity is practical constant at each
sensor since the light source is so narrow. Let's now test a wider light source by setting
the standard deviation to 1.5. Let's first look at the histogram

```julia
dist = Truncated(Normal(0, 1.0), -π/2, π/2)
θ = rand(dist, 1_000_000)
histogram(θ, label = "", xlabel = "Zenith angle", ylabel = "Prob. density", normalize=:pdf)
vline!([-π/2, π/2], label = "")
```

Now we expect a lot of rays to escaped from the sides of the scene and not hit the sensors.
Let's test this by creating a new light source and tracing the rays again.

```julia
source = Source(PointSource(Vec(0.5, 0.5, 1.0)), GaussianSource(X(), Y(), -Z(), 1.0), 1.0, 1_000_000)
settings = RTSettings(pkill = 0.9, maxiter = 1, parallel = true)
rtobj = RayTracer(mesh, source, settings = settings);
trace!(rtobj)
```

If we plot the light intensity at each sensor we will see that the sensors receive less light
than before but also the gradient of light intensity towards the shaded regions is less
pronounced.

```julia
p_wide = [power(s)[1]/1_000_000 for s in sensors]
heatmap(coords, coords, reshape(p_wide,20,20))
```
