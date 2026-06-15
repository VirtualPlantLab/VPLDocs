# Tilted slopes and unconventional row orientations

When you simulate crops in the field (or any plantation with a regular planting pattern),
VPL will assume by default that the rows are oriented North-South and that the terrain being
simulated is perfectly horizontal. However, the user may want to simulate rows that differ
in orientation and/or terrains that are not horizontal (and therefore also have an
orientation). In this how-to guide we will learn how to provide such information and
better understand the coordinate system that is use for 3D scenes in VPL.

As described in the how-to guide for the grid cloner, it is important
that the regular pattern in which plants are arranged is aligned with the X and Y axis.
Moreover, the rows (in non-square planting patterns) should always be aligned with the X
axis. That means, than when you construct the scene itself, you should do it as if you were
dealing with the default situation regardless of whether the ground is tilted or the rows are
oriented differently from the default. The orientation of the rows and the slope of the ground
are then used to modify the sky dome (from SkyDomes.jl) relative to the scene so that
calculations of solar radiation are performed correctly. Thus, you can easily simulate
different orientations and slopes by changing the creation of the sky dome (i.e., the
function `sky`) while the rest can remain the same as far as solar geometry is concerned.

Note however that when plants grow on a slope it may be important to explcitly take into
account gravitropism. That is, the shots of plants tend to grow *upwards* and the root *downwards*
and in VPL we generally associated this to the Z axis. Hovewer, on a tilted slope, the Z
axis represents the direction perpendicular to the ground but plants will still tend to grow
in the direction of gravity (you can appreciate this when looking at trees growing on
mountains). VPL does not prescribe how to deal with this situation but two main options are
possible:

1. Implement gravitropism explictly using the [`PlantGeomTurtle.RV`](@ref) and [`PlantGeomTurtle.rv!`](@ref) turtle operators and methods, respectively.

2. Rotate the turtle at the origin of the plant so that it is aligned with the graviational
axis rather than the scene's Z axis.

In the example below we will simulate a plot of simple stick-like plants (as in the
grid cloner how-to guide), adjusting the axis of the plant using the second
option above and creating the sky dome appropiately. Finally, we will indicate how to
adjust the render function to represent the slope in the ground.

## Example

Load the dependencies

```julia
using VirtualPlantLab
using SkyDomes
import ColorTypes: RGB
import GLMakie
```

A plant will be represented by a simple cylinder located at different points in a grid. The
rows are oriented East-West and the ground has a slope of 30 degrees.
We create the grid given the recommendations in the above. Using this template ensures that
the scene has the proper dimensions while still scaling with the number of plants and rows:

```julia
alpha_rows = 90.0 # Row orientation East-West
alpha_soil = 30.0
dx = 2.0
dy = 0.5
nrows = 10
nplants = 10
origins = [Vec(i,j,0) for i = dx/2:dx:(nrows - 0.5)dx, j = dy/2:dy:(nplants - 0.5)dy];
```

Notice that we do not make use of `alpha_rows` when creating the rows. Indeed, we always want
the rows to be aligned with the X axis, we will use this information when creating the light
sources from SkyDomes.jl.

We create a simple plant placeholder defined by a stem and a single long leaf:. Notice that
we adjust the orientation of the turtle by `alpha_soil` by adding an `RA` operator to the
axiom (note that `alpha_soil` is in radians while turtle operators are in degrees, this
will be fixed in future versions):

```julia
struct Plant <: Node end
function VirtualPlantLab.feed!(turtle::Turtle, plant::Plant, data)
    HollowCylinder!(turtle, move = true, colors = RGB(0.63, 0.63, 0.63), length = 2.0,
                    width = 0.25, height = 0.25)
    rh!(turtle, rand()*360.0)
    ra!(turtle, rand()*90.0)
    Rectangle!(turtle, colors = RGB(0.0, 1.0, 0.0), length = 3.0, width = 0.2)
    return nothing
end
axiom(origin) = RH(90.0) + RA(-alpha_soil) + T(origin) + Plant()
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
    rotatey!(tile, 90.0)
    VirtualPlantLab.translate!(tile, p .+ Vec(-dx/2, 0.0, 0.0))
    return tile
end
tiles = vec([create_tile(origin, dx, dy) for origin in origins]);
```

Now we can combine the plants and tiles into a single mesh. We randomize the color of each
tile to help identify them in the visualization. We can specify `alpha_soil` in the call to
`render()` which will simply adjust the initial angle of the camera to represent the tilted
slope:

```julia
plant_mesh = Mesh(vec(plants));
soil_mesh = Mesh()
for tile in tiles
    add!(soil_mesh, tile, colors = RGB(rand(), rand(), rand()))
end
mesh = Mesh([plant_mesh, soil_mesh]);
render(mesh, alpha_soil = alpha_soil)
```

Now we create the dome of light sources, using as reference the tutorial on ray traced forests. If
you have gone through that tutorial you will see that the function below is the same but we have
added two arguments: `alpha` and `alpha_soil`, these must be passed to all the calls to `sky()`.
This will ensure that the light sources are genearte generated correctly according to the orientation
of the X axis (which is determined by the rows of plants) and the inclination of the field.

```julia
function create_sky(;mesh, lat = 52.0, DOY = 182, alpha_rows, alpha_soil)
    # Fraction of the day and day length
    fs = collect(0.1:0.1:0.9)
    dec = declination(DOY)
    DL = day_length(lat, dec)*3600
    # Compute solar irradiance
    temp = [clear_sky(lat = lat, DOY = DOY, f = f) for f in fs] # W/m2
    Ig   = getindex.(temp, 1)
    Idir = getindex.(temp, 2)
    Idif = getindex.(temp, 3)
    theta = getindex.(temp, 4)
    phi  = getindex.(temp, 5)
    # Conversion factors to PAR for direct and diffuse irradiance
    f_dir = waveband_conversion(Itype = :direct,  waveband = :PAR, mode = :power)
    f_dif = waveband_conversion(Itype = :diffuse, waveband = :PAR, mode = :power)
    # Actual irradiance per waveband
    Idir_PAR = f_dir.*Idir
    Idif_PAR = f_dif.*Idif
    # Create the dome of diffuse light
    dome = sky(mesh,
                  Idir = 0.0, ## No direct solar radiation
                  Idif = sum(Idif_PAR)/10*DL, ## Daily Diffuse solar radiation
                  nrays_dif = 1_000_000, ## Total number of rays for diffuse solar radiation
                  sky_model = StandardSky, ## Angular distribution of solar radiation
                  dome_method = equal_solid_angles, # Discretization of the sky dome
                  ntheta = 9, ## Number of discretization steps in the zenith angle
                  nphi = 12, ## Number of discretization steps in the azimuth angle
                  α = alpha_rows, ## Orientation of the rows
                  alpha_soil = alpha_soil) ## Inclination of the field
    # Add direct sources for different times of the day
    for i in eachindex(Idir_PAR)
        push!(dome, sky(mesh, Idir = Idir_PAR[i]/10*DL, nrays_dir = 100_000, Idif = 0.0,
                        theta_dir = theta[i], phi_dir = phi[i], α = alpha_rows,
                        alpha_soil = alpha_soil)[1])
    end
    return dome
end
acc_scene = accelerate(mesh)
sky_dome = create_sky(mesh = acc_scene, lat = 52.0, DOY = 182, alpha_rows = alpha_rows, alpha_soil = alpha_soil);
```

Notice that we received a warning because some of the light sources cannot reach the field (i.e., the fall on the other side 
of the mountain or hill that we are implicitly simulating). We can now add the dome to the rendering:

```julia
render(mesh, alpha_soil = alpha_soil)
render!(sky_dome)
```