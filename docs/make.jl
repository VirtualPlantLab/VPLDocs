using VPLDocs
using Documenter
import PlantGraphs, PlantGeomPrimitives, PlantGeomTurtle, PlantRayTracer, PlantViz, SkyDomes, Ecophys, PlantSimEngine

makedocs(;
    doctest = false,
    modules = [VPLDocs, PlantGraphs, PlantGeomPrimitives, PlantGeomTurtle, PlantRayTracer, PlantViz, SkyDomes, Ecophys, PlantSimEngine],
    authors="Alejandro Morales <alejandro.moralessierra@wur.nl> and contributors",
    repo="https://github.com/VirtualPlantLab/VPLDocs/blob/{commit}{path}#{line}",
    sitename="Virtual Plant Laboratory",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        edit_link="master",
        assets=String[],
        collapselevel = 1,
        footer = nothing
    ),
    pages=[
        "Virtual Plant Laboratory" => "index.md",
        "Manual" => [
            "Julia basic concepts" => "manual/Julia.md",
            "Dynamic graph creation and manipulation" => "manual/Graphs.md",
            "Geometry primitives" => "manual/Geometry/Primitives.md",
            "Turtle geometry and scenes" => "manual/Geometry/Turtle.md",
            "Ray tracing" => "manual/Raytracer.md",
            "3D visualization" => "manual/Visualization.md"
        ],
        "Tutorials" => [
            "Algae growth" => "tutorials/algae.md",
            "The Koch snowflake" => "tutorials/snowflakes.md",
            "Tree" => "tutorials/tree.md",
            "Forest" => "tutorials/forest.md",
            "Growth forest" => "tutorials/growthforest.md",
            "Ray-traced forest" => "tutorials/raytracedforest.md",
            "Context sensitive rules" => "tutorials/context.md",
            "Relational queries" => "tutorials/relationalqueries.md"
        ],
        "How-to guides" => [
            "Setting up a grid cloner" => "howto/GridCloner.md"
        ],
        "API" => [
            "Graphs" => "api/graphs.md",
            "Scenes and 3D meshes" => "api/geometry.md",
            "Turtle geometry" => "api/turtle.md",
            "Ray tracing" => "api/raytracer.md",
            "3D visualization" => "api/viz.md"
        ],
        "VPLVerse" => [
            "SkyDomes" => [
                "SkyDomes package" => "VPLVerse/SkyDomes/index.md",
                "SkyDomes API" => "VPLVerse/SkyDomes/API.md"
            ],
            "Ecophys" => [
                "Ecophys package" => "VPLVerse/Ecophys/index.md",
                "Photosynthesis API" => "VPLVerse/Ecophys/photosynthesis.md"
            ],
            "PlantSimEngine" => [
                "PlantSimEngine package" => "VPLVerse/PlantSimEngine/index.md"
            ],
            "PlantBioPhysics" => [
                "PlantBioPhysics package" => "VPLVerse/PlantBioPhysics/index.md"
            ]
        ],
        "Developers" => [
            "Internal organization" => "developers/organization.md"
        ]
    ],
)

deploydocs(;
    repo="github.com/VirtualPlantLab/VPLDocs",
    devbranch="master",
)
