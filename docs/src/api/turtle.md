
# Turtle Geometry

```@meta
CurrentModule = PlantGeomTurtle
```

API documentation for [PlantGeomTurtle.jl](https://github.com/VirtualPlantLab/PlantGeomTurtle.jl).

## Turtle geometry

```@docs
Turtle(::Type{T} = Float64) where T
```

```@docs
head(turtle::Turtle)
up(turtle::Turtle)
arm(turtle::Turtle)
pos(turtle::Turtle)
```

```@docs
geoms(turtle::Turtle)
colors(turtle::Turtle)
faces(turtle::Turtle)
materials(turtle::Turtle)
```

```@docs
feed!
```

```@docs
Scene
```

```@docs
T
t!(turtle::Turtle; to)
```

```@docs
OR
or!(turtle::Turtle; head, up, arm)
```

```@docs
SET
set!(turtle::Turtle; to, head, up, arm)
```

```@docs
RU
ru!(turtle::Turtle{FT,UT}, angle::FT) where {FT,UT}
```

```@docs
RA
ra!(turtle::Turtle{FT,UT}, angle::FT) where {FT,UT}
```

```@docs
RH
rh!(turtle::Turtle{FT,UT}, angle::FT) where {FT,UT}
```

```@docs
F
f!(turtle::Turtle{FT,UT}, dist::FT) where {FT,UT}
```

```@docs
RV
rv!(turtle::Turtle{FT,UT}, strength::FT) where {FT,UT}
```

## Geometry primitives

### Triangle

```@docs
Triangle!(turtle::Turtle{FT}; length::FT = one(FT), width::FT = one(FT),
                    move = false, material = nothing, color = nothing) where FT
```

### Rectangle

```@docs
Rectangle!(turtle::Turtle{FT}; length::FT = one(FT), width::FT = one(FT),
                    move = false, material = nothing, color = nothing) where FT
```

### Trapezoid

```@docs
Trapezoid!(turtle::Turtle{FT}; length::FT = one(FT), width::FT = one(FT), ratio::FT = one(FT),
                    move = false, material = nothing, color = nothing) where FT
```

### Ellipse

```@docs
Ellipse!(turtle::Turtle{FT}; length = one(FT), width = one(FT), n = 20,
                    move = false, material = nothing, color = nothing) where FT
```

### Hollow cylinder

```@docs
HollowCylinder!(turtle::Turtle{FT}; length::FT = 1.0, width::FT = 1.0, height::FT = 1.0, n::Int = 40) where FT
SolidCylinder!(turtle::Turtle{FT}; length::FT = 1.0, width::FT = 1.0, height::FT = 1.0, n::Int = 80) where FT
```

### Hollow cone

```@docs
HollowCone!(turtle::Turtle{FT}; length::FT = one(FT), width::FT = one(FT), height::FT = one(FT), n::Int = 20,
                    move = false, material = nothing, color = nothing) where FT
SolidCone!(turtle::Turtle{FT}; length::FT = one(FT), width::FT = one(FT), height::FT = one(FT), n::Int = 40,
                    move = false, material = nothing, color = nothing) where FT
```

### Cube

```@docs
SolidCube!(turtle::Turtle{FT}; length::FT = one(FT), width::FT = one(FT), height::FT = one(FT),
                    move = false, material = nothing, color = nothing) where FT
HollowCube!(turtle::Turtle{FT}; length::FT = one(FT), width::FT = one(FT), height::FT = one(FT),
                    move = false, material = nothing, color = nothing) where FT
```

### Solid frustum

```@docs
SolidFrustum!(turtle::Turtle{FT}; length::FT = one(FT), width::FT = one(FT), height::FT = one(FT), ratio::FT = one(FT), n::Int = 80,
                    move = false, material = nothing, color = nothing) where FT
HollowFrustum!(turtle::Turtle{FT}; length::FT = one(FT), width::FT = one(FT), height::FT = one(FT), ratio::FT = one(FT), n::Int = 40,
                    move = false, material = nothing, color = nothing) where FT
```

### Generic mesh

```@docs
Mesh!(turtle::Turtle{FT}, m::Mesh; scale::Vec{FT} = Vec{FT}(1.0,1.0,1.0),
               move = false) where FT
```
