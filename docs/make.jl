using VPLDocs
using Documenter
import PlantGraphs, PlantGeomPrimitives, PlantGeomTurtle, PlantRayTracer, PlantViz, SkyDomes, Ecophys

makedocs(;
    doctest = false,
    modules=[VPLDocs, PlantGraphs, PlantGeomPrimitives, PlantGeomTurtle, PlantRayTracer, PlantViz, SkyDomes, Ecophys],
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
            "Algae growth" => "tutorials/Algae/Algae.md",
            "The Koch snowflake" => "tutorials/Snowflakes/Snowflakes.md",
            "Tree" => "tutorials/Tree/Tree.md",
            "Forest" => "tutorials/Forest/Forest.md",
            "Growth forest" => "tutorials/GrowthForest/GrowthForest.md",
            "Ray-traced forest" => "tutorials/RaytracedForest/RaytracedForest.md",
            "Context sensitive rules" => "tutorials/Context/Context.md",
            "Relational queries" => "tutorials/RelationalQueries/RelationalQueries.md"
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
                "SkyDomes package" => "SkyDomes/index.md",
                "SkyDomes API" => "SkyDomes/API.md"
            ],
            "Ecophys" => [
                "Ecophys package" => "Ecophys/index.md",
                "Photosynthesis API" => "Ecophys/photosynthesis.md"
            ],
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
