# Canopy photosynthesis

Alejandro Morales

Centre for Crop Systems Analysis - Wageningen University

> ## TL;DR
> Similar in functionality to [Forest](https://virtualplantlab.com/dev/tutorials/from_tree_forest/forest/) tutorial with photosynthesis
> - Run ray tracer multiple times per day using Gaussian integration
> - Compute photosynthesis at each time point
> - Aggregate photosynthesis to the tree and daily scales

In this tutorial we will add photosynthesis calculations to the forest model (for
simplicity we will still grow the trees descriptively, but this could be extended
to a full growth model including respiration, carbon allocation, etc.).

We start with the code from the [forest](./forest.md) with the following additions:

  * Load the Ecophys.jl package
  * Add materials to internodes, leaves and soil tile
  * Keep track of absorbed PAR within each leaf
  * Compute daily photosynthesis for each leaf using Gaussian-Legendre integration over the day
  * Integrate to the tree level

```julia
using VirtualPlantLab, Distributions, Plots, Ecophys, SkyDomes, FastGaussQuadrature
import Base.Threads: @threads
import Random
Random.seed!(123456789)
import GLMakie
# Data types
module TreeTypes
    import VirtualPlantLab as VPL
    import Ecophys
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
        mat::VPL.Lambertian{1} = VPL.Lambertian(τ = 0.00, ρ = 0.05)
    end
    # Leaf
    Base.@kwdef mutable struct Leaf <: VPL.Node
        length::Float64 = 0.20 # Leaves are 20 cm long
        width::Float64  = 0.1 # Leaves are 10 cm wide
        PARdif::Float64 = 0.0
        PARdir::Float64 = 0.0
        mat::VPL.Lambertian{1} = VPL.Lambertian(τ = 0.05, ρ = 0.1)
        Ag::Float64 = 0.0
    end
    # Graph-level variables
    Base.@kwdef mutable struct treeparams
        growth::Float64 = 0.1
        budbreak::Float64 = 0.25
        phyllotaxis::Float64 = 140.0
        leaf_angle::Float64 = 30.0
        branch_angle::Float64 = 45.0
        photos::Ecophys.C3{Float64} = Ecophys.C3()
        Ag::Float64 = 0.0
    end
end

import .TreeTypes

# Create geometry + color for the internodes
function VirtualPlantLab.feed!(turtle::Turtle, i::TreeTypes.Internode, vars)
    # Rotate turtle around the head to implement elliptical phyllotaxis
    rh!(turtle, vars.phyllotaxis)
    HollowCylinder!(turtle, length = i.length, height = i.length/15, width = i.length/15,
                move = true, colors = RGB(0.5,0.4,0.0), materials = i.mat)
    return nothing
end

# Create geometry + color for the leaves
function VirtualPlantLab.feed!(turtle::Turtle, l::TreeTypes.Leaf, vars)
    # Rotate turtle around the arm for insertion angle
    ra!(turtle, -vars.leaf_angle)
    # Generate the leaf
    Ellipse!(turtle, length = l.length, width = l.width, move = false,
             colors = RGB(0.2,0.6,0.2), materials = l.mat)
    # Rotate turtle back to original direction
    ra!(turtle, vars.leaf_angle)
    return nothing
end

# Insertion angle for the bud nodes
function VirtualPlantLab.feed!(turtle::Turtle, b::TreeTypes.BudNode, vars)
    # Rotate turtle around the arm for insertion angle
    ra!(turtle, -vars.branch_angle)
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
    steps = Int(ceil(steps/2)) # Because it will count both the nodes and the internodes
    # Compute probability of bud break and determine whether it happens
    if check
        prob =  min(1.0, steps*graph_data(bud).budbreak)
        return rand() < prob
    # If there is no meristem, an error happened since the model does not allow for this
    else
        error("No meristem found in branch")
    end
end
branch_rule = Rule(TreeTypes.Bud,
            lhs = prob_break,
            rhs = bud -> TreeTypes.BudNode() + TreeTypes.Internode() + TreeTypes.Meristem())

function create_tree(origin, growth, budbreak, orientation)
    axiom = T(origin) + RH(orientation) + TreeTypes.Internode() + TreeTypes.Meristem()
    tree =  Graph(axiom = axiom, rules = (meristem_rule, branch_rule),
                  data = TreeTypes.treeparams(growth = growth, budbreak = budbreak))
    return tree
end

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
origins = [Vec(i,j,0) for i = 1:2.0:20.0, j = 1:2.0:20.0]
orientations = [rand()*360.0 for i = 1:2.0:20.0, j = 1:2.0:20.0]
growths = rand(LogNormal(-2, 0.3), 10, 10)
budbreaks = rand(Beta(2.0, 10), 10, 10)
forest = vec(create_tree.(origins, growths, budbreaks, orientations));
```

We run the simulation for a few steps to create a forest and add the soil:

```julia
newforest = [simulate(tree, getInternode, 15) for tree in forest];
scene = Mesh(newforest);
soil = Rectangle(length = 21.0, width = 21.0)
rotatey!(soil, pi/2)
VirtualPlantLab.translate!(soil, Vec(0.0, 10.5, 0.0))
VirtualPlantLab.add!(scene, soil, colors = RGB(1,1,0),
                materials = Lambertian(τ = 0.0, ρ = 0.21))
#render(scene, backend = "web", resolution = (800, 600))
```

Unlike in the previous example, we can no longer run a single raytracer to
compute daily photosynthesis, because of its non-linear response to irradiance.
Instead, we need to compute photosynthesis at different time points during the
day and integrate the results (e.g., using a Gaussian quadrature rule). However,
this does not require more computation than the previous example if the calculations
are done carefully to avoid redundancies.

Firstly, we can create the bounding volume hierarchy and grid cloner around the
scene once for the whole day using the `accelerate()` function (normally this is called
by VPL internally):

```julia
settings = RTSettings(pkill = 0.8, maxiter = 3, nx = 5, ny = 5, dx = 20.0,
                          dy = 20.0, parallel = true)
acc_scene = accelerate(scene, settings = settings, acceleration = BVH,
                       rule = SAH{6}(1,20));
```

Then we compute the relative fraction of diffuse PAR that reaches each leaf (once
for the whole day):

```julia
get_leaves(tree) = apply(tree, Query(TreeTypes.Leaf))

function calculate_diffuse!(;acc_scene, forest, lat = 52.0*π/180.0, DOY = 182)
    # Create the dome of diffuse light
    dome = sky(acc_scene,
                  Idir = 0.0, # No direct solar radiation
                  Idif = 1.0, # In order to get relative values
                  nrays_dif = 1_000_000, # Total number of rays for diffuse solar radiation
                  sky_model = StandardSky, # Angular distribution of solar radiation
                  dome_method = equal_solid_angles, # Discretization of the sky dome
                  ntheta = 9, # Number of discretization steps in the zenith angle
                  nphi = 12) # Number of discretization steps in the azimuth angle
    # Ray trace the scene
    settings = RTSettings(pkill = 0.9, maxiter = 4, nx = 5, ny = 5, dx = 20.0,
                          dy = 20.0, parallel = true)
    # Because the acceleration was pre-computed, use direct RayTracer constructor
    rtobj = RayTracer(acc_scene, dome, settings = settings);
    trace!(rtobj)
    # Transfer power to PARdif
    @threads for tree in forest
        for leaf in get_leaves(tree)
            leaf.PARdif = power(leaf.mat)[1]/(π*leaf.length*leaf.width/4)
        end
    end
    return nothing
end
```

Once the relative diffuse irradiance has been computed, we can loop over the
day and compute direct PAR by using a single ray tracer and update photosynthesis
from that. Notice that here we convert solar radiation to PAR in umol/m2/s as
opposed to W/m2 (using `:flux` rather than `:power` in the `waveband_conversion`
function):

```julia
function calculate_photosynthesis!(;acc_scene, forest, lat = 52.0*π/180.0, DOY = 182,
                 f = 0.5, w = 0.5, DL = 12*3600)
    # Compute the solar irradiance assuming clear sky conditions
    Ig, Idir, Idif = clear_sky(lat = lat, DOY = DOY, f = f)
    # Conversion factors to PAR for direct and diffuse irradiance
    PARdir = Idir*waveband_conversion(Itype = :direct,  waveband = :PAR, mode = :flux)
    PARdif = Idif*waveband_conversion(Itype = :diffuse, waveband = :PAR, mode = :flux)
    # Create the light source for the ray tracer
    dome = sky(acc_scene, Idir = PARdir, nrays_dir = 100_000, Idif = 0.0)
    # Ray trace the scene
    settings = RTSettings(pkill = 0.9, maxiter = 4, nx = 5, ny = 5, dx = 20.0,
                          dy = 20.0, parallel = true)
    rtobj = RayTracer(acc_scene, dome, settings = settings)
    trace!(rtobj)
    # Transfer power to PARdif
    @threads for tree in forest
        ph = data(tree).photos
        for leaf in get_leaves(tree)
            leaf.PARdir = power(leaf.mat)[1]/(π*leaf.length*leaf.width/4)
            leaf_PARdif = leaf.PARdif*PARdif
            PAR = leaf.PARdir + leaf_PARdif
            leaf.Ag += (photosynthesis(ph, PAR = PAR).A + ph.Rd25)*w*DL
        end
    end
    return nothing
end

# Reset photosynthesis
function reset_photosynthesis!(forest)
    @threads for tree in forest
        for leaf in get_leaves(tree)
            leaf.Ag = 0.0
        end
    end
    return nothing
end
```

This function may now be run for different time points during the day based on
a Gaussian quadrature rule:

```julia
function daily_photosynthesis(forest; DOY = 182, lat = 52.0*π/180.0)
    # Compute fraction of diffuse irradiance per leaf
    calculate_diffuse!(acc_scene = acc_scene, forest = forest, DOY = DOY, lat = lat);
    # Gaussian quadrature over the
    NG = 5
    f, w = gausslegendre(NG)
    w ./= 2.0
    f .= (f .+ 1.0)/2.0
    # Reset photosynthesis
    reset_photosynthesis!(forest)
    # Loop over the day
    dec = declination(DOY)
    DL = day_length(lat, dec)*3600
    for i in 1:NG
        println("step $i out of $NG")
        calculate_photosynthesis!(acc_scene = acc_scene, forest = forest,
                                  f = f[i], w = w[i], DL = DL, DOY = DOY, lat = lat)
    end
end
```

And we scale to the tree level with a simple query:

```julia
function canopy_photosynthesis!(forest)
    # Integrate photosynthesis over the day at the leaf level
    daily_photosynthesis(forest)
    # Aggregate to the the tree level
    Ag = Float64[]
    for tree in forest
        data(tree).Ag = sum(leaf.Ag*π*leaf.length*leaf.width/4 for leaf in get_leaves(tree))
        push!(Ag, data(tree).Ag)
    end
    return Ag/1e6 # mol/tree
end

# Run the canopy photosynthesis model
Ag = canopy_photosynthesis!(newforest);

# Visualize distribution of tree photosynthesis
histogram(Ag)
```
