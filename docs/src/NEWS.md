# VPL release notes

We started keeping track of changes after version 1.0.0. For 
details on the changes please refer to the `NEWS.md` of each individual
package. Also note that several projects in the VPLverse are handled 
independently from  the main VPL development. We document their public API
in this website for convenience but do not keep track of updates to those
packages, so please check their (more detailed) individual documentation
sites and Github repositories.

# VPL 1.0.2

- VPL now supports creating spheres, spheroids and ellipsoids with the primitive
constructors `Ellipsoid` and `Ellipsoid!`. Please consult documentation for details.

# Ecophys 0.1.2

Bug fixes and improve test suite (output will change stomatal conductance, gs, when using both C3 and C4 models, no changes to API).

- Switch to solving for Ci and then calculate gs inside the analytical functions of C3 and C4 photosynthesis instead of solving for gs directly (this was causing wrong values of gs).

- Add a bunch of tests to better verify several properties of response curves of CO2 assimilation and stomatal conductance.

# VPL 1.0.1

- All functions across all VPLcore packages and SkyDomes.jl now use angles in 
hexadecimal degrees, also unexported functions. **Your code may need to be updated**

# VPL 1.0.0

- We have updated PlantRayTracer.jl, PlantViz.jl and SkyDomes.jl in order to account for
rows of crops that are not orienteds North-South as well as fields that are not
horizontal (tilted, oriented slopes). The default parameter values reproduce the original
situation (horizontal field, North-South rows of plants). **Your code does not need to be updated**. 
A how-to guide has been added explaining how to make use of these features.

- All exported functons in SkyDomes.jl no take angles as inputs (or return angles as outputs)
in hexadecimal degrees, rather than radians. **Your code may need to be updated**