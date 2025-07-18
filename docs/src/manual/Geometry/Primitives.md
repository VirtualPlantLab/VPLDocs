# [Geometry primitives](@id manual_primitives)

Alejandro Morales

Centre for Crop Systems Analysis - Wageningen University


```julia
using VirtualPlantLab
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
turtle = Turtle()
p = Triangle!(turtle; length = 1.0, width = 1.0, colors = rand(RGBA))    
render(Mesh(turtle), wireframe = true)
```

## Rectangle
```julia
turtle = Turtle()
p = Rectangle!(turtle; length = 1.0, width = 1.0, colors = rand(RGBA)) 
render(Mesh(turtle), wireframe = true)
```

## Trapezoid
```julia
turtle = Turtle()
p = Trapezoid!(turtle; length = 1.0, width = 1.0, ratio = 0.5, colors = rand(RGBA))
render(Mesh(turtle), wireframe = true)
```

## Ellipse
```julia
turtle = Turtle()
p = Ellipse!(turtle; length = 1.0, width = 1.0, n = 30, colors = rand(RGBA))
render(Mesh(turtle), wireframe = true)
```

## Axis-aligned bounding box
```julia
turtle = Turtle()
p = BBox(Vec(0.0, 0.0, 0.0), Vec(1.0, 1.0, 1.0))
Mesh!(turtle, p, colors = rand(RGBA))
render(Mesh(turtle), wireframe = true)
```

## Cube

Solid version

```julia
turtle = Turtle()
p = SolidCube!(turtle; length = 1.0, width = 1.0, height = 1.0, colors = rand(RGBA))
render(Mesh(turtle), wireframe = true)
```

Hollow version

```julia
turtle = Turtle()
p = HollowCube!(turtle; length = 1.0, width = 1.0, height = 1.0, colors = rand(RGBA))
render(Mesh(turtle), wireframe = true)
```

## Primitives with (semi-)circular bases

The following primitive types share a parameter n, which is the number of triangles to discretize the cylinder into.
The lower is number n, cicle base shape will be more rough (e.g., n = 20, base shape is a pentagon).
The higher is number n, cicle base shape will be more smooth (e.g., n = 80, base shape is a circle).
The same analogy also apply to ellipse; see above, in this case n = 5 the shape is a pentagon, and n = 30 the shape is elipsoidal.

## Cylinder

Solid version

```julia
turtle = Turtle()
p = SolidCylinder!(turtle; length = 1.0, width = 1.0, height = 1.0, n = 80, colors = rand(RGBA))
render(Mesh(turtle), wireframe = true)
```

Hollow version

```julia
turtle = Turtle()
p = HollowCylinder!(turtle; length = 1.0, width = 1.0, height = 1.0, n = 80, colors = rand(RGBA))
render(Mesh(turtle), wireframe = true)
```

## Frustum

Solid version

```julia
turtle = Turtle()
p = SolidFrustum!(turtle; length = 1.0, width = 1.0, height = 1.0, ratio = 0.5, n = 80, colors = rand(RGBA))
render(Mesh(turtle), wireframe = true)
```

Hollow version

```julia
turtle = Turtle()
p = HollowFrustum!(turtle; length = 1.0, width = 1.0, height = 1.0, ratio = 0.5, n = 80, colors = rand(RGBA))
render(Mesh(turtle), wireframe = true)
```

## Cone

Solid version

```julia
turtle = Turtle()
p = SolidCone!(turtle; length = 1.0, width = 1.0, height = 1.0, n = 80, colors = rand(RGBA))
render(Mesh(turtle), wireframe = true)
```

Hollow version

```julia
turtle = Turtle()
p = HollowCone!(turtle; length = 1.0, width = 1.0, height = 1.0, n = 80, colors = rand(RGBA))
render(Mesh(turtle), wireframe = true)
```
