# How to drive a ray tracer with SkyDomes

Alejandro Morales

Centre for Crop Systems Analysis - Wageningen University

The [SkyDomes](../VPLVerse/SkyDomes/index.md) package turns information about
solar radiation into the collection of light sources that VPL's ray tracer needs
to compute light interception in a 3D scene. The amount of information we have
about the radiation on a given day can vary depending on the context: sometimes
we only know the location and date, sometimes we have a daily total measured at a
weather station, and sometimes we have a high-frequency time series from a
weather station or pyranometer. This guide shows how to use the available data on
solar radiation to create a sky dome of light sources. The relevant functions
from the SkyDome package are `clear_sky`, `cloudy_sky` and `daily_radiation`.

We cover four scenarios, in increasing order of how much we know about solar
radiation:

1. Asumme clear (cloudless) day, using `clear_sky`.
2. A cloudy day for which we only assume the daily global radiation is one third
   of the clear-sky expectation, combining `daily_radiation` and `cloudy_sky`.
3. A day for which we know the *measured* daily global radiation, again combining
   `daily_radiation` and `cloudy_sky`.
4. A day for which we have a *time series* of measured global radiation (e.g. one
   value per minute from a CSV file), using `cloudy_sky` directly.

In all four scenarios below, the scene, the wavebands and the way the light sources are
built are exactly the same; only the calculation of the direct and diffuse
irradiance changes. That calculation is the part we want to highlight here.

!!! note "Units and conventions"
    - `clear_sky` and `cloudy_sky` return **instantaneous** irradiance in W/m².
    - `daily_radiation` returns **daily totals** in J/m² (note: J, not MJ).
    - The latitude `lat` is given in **degrees** (positive in the Northern
      hemisphere).
    - The time of day is given as a fraction `f` of daytime, with
      `f = 0` at sunrise and `f = 1` at sunset.

## Packages

```julia
using VirtualPlantLab
using SkyDomes
import ColorTypes: RGB
import GLMakie
import Random
Random.seed!(123456789)
```

## A simple scene of plants and soil

We build a minimal scene: a small grid of placeholder plants (a stem and a single
leaf) together with one soil tile per plant. The leaf and the soil get optical
properties (a `Lambertian` material), which is what allows the ray tracer to
compute absorbed radiation. Because we want to resolve several wavebands at once
(red, green, blue and NIR), each material carries **four** wavebands, i.e. it is a
`Lambertian{4}` whose `τ` (transmittance) and `ρ` (reflectance) are tuples with
one value per waveband:

```julia
# Order of the wavebands used throughout this guide
const wavebands = (:red, :green, :blue, :NIR)

# A leaf transmits and reflects little in the visible but a lot in the NIR
leaf_material() = Lambertian(τ = (0.05, 0.10, 0.04, 0.45),
                             ρ = (0.10, 0.20, 0.05, 0.45))
# Soil does not transmit light and reflects moderately
soil_material() = Lambertian(τ = (0.00, 0.00, 0.00, 0.00),
                             ρ = (0.15, 0.20, 0.10, 0.30))
# The stems have same optical properties as soil
stem_material() = Lambertian(τ = (0.00, 0.00, 0.00, 0.00),
                             ρ = (0.15, 0.20, 0.10, 0.30))
```

A plant is a stem plus three leaves. Note that for simplicity we define a plant a single node, 
normally for more complex models each internode and leaf would be their own node, but that is not
an axiom, always built the simplest model that does the job (it may not even need a graph!):

```julia
Base.@kwdef mutable struct Plant <: Node
    leaf_mat::Vector{Lambertian{4}} = [leaf_material() for _ in 1:3]
    stem_mat::Vector{Lambertian{4}} = [stem_material() for _ in 1:3]
end
function VirtualPlantLab.feed!(turtle::Turtle, p::Plant, data)
    for i in 1:3
        HollowCylinder!(turtle, length = 0.05 + rand()*0.1, width = 0.01, height = 0.01, move = true,
                        colors = RGB(0.6, 0.4, 0.1), materials = p.stem_mat[i])
        rh!(turtle, -138.0) # Phyllotaxis
        ra!(turtle, -45.0)  # Insertion angle
        Ellipse!(turtle, length = 0.1, width = 0.05, move = false,
                colors = RGB(0.2, 0.6, 0.2), materials = p.leaf_mat[i])
        ra!(turtle, 45.0)  # Undo insertion angle               
    end
    return nothing
end
```

We place the plants on a regular grid, remember that rows of crops follow the x
axis:

```julia
dx = 0.1      # spacing between rows
dy = 0.25      # spacing within rows
nrows = 4
nplants = 10
origins = [Vec(i, j, 0.0) for i in dx/2:dx:(nplants - 0.5)dx,
                              j in dy/2:dy:(nrows - 0.5)dy]
plants = [Graph(axiom = T(o) + RH(rand()*360.0) + Plant()) for o in vec(origins)];
```

Each plant gets a soil tile centred on it. We keep the soil materials in a vector
so we can query the absorbed radiation afterwards:

```julia
function create_tile(p, dx, dy)
    tile = Rectangle(length = dx, width = dy)
    rotatey!(tile, 90.0)                                   ## put it in the XY plane
    VirtualPlantLab.translate!(tile, p .+ Vec(-dx/2, 0.0, 0.0))
    return tile
end

plant_mesh = Mesh(vec(plants))
soil_mesh = Mesh()
soil_materials = Lambertian{4}[]
for o in vec(origins)
    m = soil_material()
    push!(soil_materials, m)
    add!(soil_mesh, create_tile(o, dx, dy), colors = RGB(0.8, 0.7, 0.5), materials = m)
end
scene = Mesh([plant_mesh, soil_mesh]);
render(scene)
```

The `sky` function places its light sources relative to a scene that has a grid
cloner, so we must `accelerate` the scene first (this creates the grid cloner
and other internal organization for ray tracer). The clone distances are set to
the full size of the scene so that the field is tiled seamlessly (i.e., always 
determine the clone distance with the `dx` and `dy` of your planting pattern):

```julia
settings = RTSettings(parallel = true, nx = 5, ny = 5, dx = nplants*dx, dy = nrows*dy)
acc_scene = accelerate(scene, settings = settings);
```

## Wavebands and a helper to build the light sources

The radiation models return irradiance integrated over the whole solar spectrum
(W/m²). The function `waveband_conversion` splits this into a specific waveband
(and, optionally, converts W/m² to µmol/m²/s). The conversion coefficients differ
for direct and diffuse radiation, so we keep them separate. The following helper
turns a single global irradiance value into a tuple with one value per waveband, in
the same order as our materials:

```julia
function to_wavebands(I, Itype)
    Tuple(I * waveband_conversion(Itype = Itype, waveband = w, mode = :power)
          for w in wavebands)
end
```

For example, the direct and diffuse conversion factors for our four wavebands are:

```julia
[waveband_conversion(Itype = :direct,  waveband = w, mode = :power) for w in wavebands]
[waveband_conversion(Itype = :diffuse, waveband = w, mode = :power) for w in wavebands]
```

Finally, a small helper builds the dome of diffuse sources plus the direct source
given the per-waveband irradiances and the position of the sun. This is the only
call to `sky` we need; every scenario below ends by calling it:

```julia
function build_sources(acc_scene, Idir_wb, Idif_wb, theta, phi)
    sky(acc_scene,
        Idir = Idir_wb,                 ## direct irradiance per waveband (tuple)
        nrays_dir = 100_000,            ## rays for the direct source
        theta_dir = theta,              ## solar zenith angle (degrees)
        phi_dir = phi,                  ## solar azimuth angle (degrees)
        Idif = Idif_wb,                 ## diffuse irradiance per waveband (tuple)
        nrays_dif = 1_000_000,          ## total rays for the diffuse dome
        sky_model = StandardSky,        ## angular distribution of diffuse radiation
        dome_method = equal_solid_angles,
        ntheta = 9, nphi = 12)
end
```

We will set the location and date once and reuse them everywhere:

```julia
lat = 52.0   # degrees North
DOY = 182    # day of year (1 July)
```

## Scenario 1: a clear, cloudless day

When we only know the location and date and assume a cloudless sky, `clear_sky`
gives the instantaneous global, direct and diffuse irradiance (W/m²) together with
the solar zenith and azimuth angles. Here we evaluate it at solar noon
(`f = 0.5`):

```julia
res = clear_sky(lat = lat, DOY = DOY, f = 0.5)
Idir_wb = to_wavebands(res.Idir, :direct)
Idif_wb = to_wavebands(res.Idif, :diffuse)
sources_clear = build_sources(acc_scene, Idir_wb, Idif_wb, res.theta, res.phi);
```

## Scenario 2: a cloudy day at one third of the clear-sky total

Now suppose we expect a cloudy day and only assume that the daily global radiation
will be one third of what a clear sky would deliver. First we obtain the clear-sky
expectation: calling `daily_radiation` *without* a measured value returns the
clear-sky daily totals (J/m²), from which we take `Igd` (the daily global):

```julia
clear_day = daily_radiation(lat = lat, DOY = DOY)   # clear-sky daily totals (J/m²)
Igd_cloudy = clear_day.Igd / 3                       # our cloudy assumption
```

Calling `daily_radiation` again, now *with* this lower daily global, repartitions
it into the direct and diffuse daily components using the Spitters et al. (1986)
relationships (more clouds means a larger diffuse fraction):

```julia
Iday = daily_radiation(lat = lat, DOY = DOY, Igd = Igd_cloudy)
```

`cloudy_sky` then turns these daily totals into the instantaneous irradiance at a
given time of day (here again solar noon), assuming the relative diurnal pattern
of each radiation component:

```julia
res = cloudy_sky(Iday = Iday, lat = lat, DOY = DOY, f = 0.5)
Idir_wb = to_wavebands(res.Idir, :direct)
Idif_wb = to_wavebands(res.Idif, :diffuse)
sources_cloudy = build_sources(acc_scene, Idir_wb, Idif_wb, res.theta, res.phi);
```

## Scenario 3: a known measured daily global radiation

If instead we have an *observed* daily global radiation for the day (for example
from a nearby weather station), the workflow is the same as in Scenario 2 but we
pass the measured value directly to `daily_radiation`. Remember that the input is
in J/m² (so a measurement of 12 MJ/m²/day is `12e6`):

```julia
Igd_obs = 12e6   # measured daily global radiation in J/m²
Iday = daily_radiation(lat = lat, DOY = DOY, Igd = Igd_obs)
res = cloudy_sky(Iday = Iday, lat = lat, DOY = DOY, f = 0.5)
Idir_wb = to_wavebands(res.Idir, :direct)
Idif_wb = to_wavebands(res.Idif, :diffuse)
sources_obs = build_sources(acc_scene, Idir_wb, Idif_wb, res.theta, res.phi);
```

## Scenario 4: a measured time series of global radiation

In the most data-rich case we have a time series of measured global radiation, for
example one value per minute logged by a pyranometer. Here we no longer need
`daily_radiation`: each measurement is an instantaneous global irradiance (W/m²)
that we can hand to `cloudy_sky` directly through its `Ig` argument, which then
returns the direct and diffuse split and the solar position for that instant.

In a real application we would load the series from a file, e.g.

```julia
using CSV, DataFrames
df = CSV.read("radiation.csv", DataFrame)   # columns: :hour and :Ig (W/m²)
```

For each measurement we convert the clock time to `f`, call `cloudy_sky` with the
measured `Ig`, and build the corresponding light sources. We skip night-time rows
(where `Ig` is zero) to avoid building empty domes:

```julia
function sources_from_measurement(acc_scene, Ig, t; lat, DOY, DL, tsr)
    f = (t - tsr)/DL
    res = cloudy_sky(Ig = Ig, lat = lat, DOY = DOY, f = f)
    Idir_wb = to_wavebands(res.Idir, :direct)
    Idif_wb = to_wavebands(res.Idif, :diffuse)
    build_sources(acc_scene, Idir_wb, Idif_wb, res.theta, res.phi)
end

daytime = filter(row -> row.Ig > 0.0, df)
sources_series = [sources_from_measurement(acc_scene, row.Ig, row.hour;
                      lat = lat, DOY = DOY, DL = DL, tsr = tsr)
                  for row in eachrow(daytime)];
```

Each element of `sources_series` is the set of light sources for one time step. A
typical daily simulation would ray trace the scene once per time step and
accumulate the absorbed radiation over the day (see the
[canopy photosynthesis](../tutorials/from_tree_forest/photosynthesis.md)
tutorial for that integration over the day).

## Running the ray tracer

Building the sources is the SkyDomes-specific part; running the ray tracer is the
same regardless of how the sources were obtained. As an illustration we trace the
clear-sky sources from Scenario 1 and read the absorbed radiant power per
waveband. Since we pre-computed the acceleration structure, we pass `acc_scene`
straight to the `RayTracer`:

```julia
rtobj = RayTracer(acc_scene, sources_clear, settings = settings);
trace!(rtobj)

# Total power absorbed by the soil tiles, per waveband (red, green, blue, NIR)
soil_absorbed = sum(power(m) for m in soil_materials)
```

`power` returns one value per waveband, in the same order as `wavebands`. Because
we expressed the irradiance in W/m², these values are radiant powers in W; divide
by the absorbing area to obtain an irradiance in W/m². The soil reflects and the
leaves transmit much more in the NIR than in the visible wavebands, which is why
the NIR component stands out in the results.

## See also

- The [SkyDomes package page](../VPLVerse/SkyDomes/index.md) and its
  [API reference](../VPLVerse/SkyDomes/API.md).
- [How to set up a grid cloner](./GridCloner.md), required by `sky`.
- The [ray-traced forest](../tutorials/from_tree_forest/raytracedforest.md) and
  [canopy photosynthesis](../tutorials/from_tree_forest/photosynthesis.md)
  tutorials, which integrate these light sources over the day in a full
  simulation.
