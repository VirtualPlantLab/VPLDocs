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
