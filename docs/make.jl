using VPLDocs
using Documenter
import PlantGraphs, PlantGeomPrimitives, PlantGeomTurtle, PlantRayTracer, PlantViz, SkyDomes, Ecophys, PlantSimEngine
import Ecophys.Photosynthesis, Ecophys.Growth

makedocs(;
    doctest = false,
    modules = [VPLDocs, PlantGraphs, PlantGeomPrimitives, PlantGeomTurtle, PlantRayTracer,
               PlantViz, SkyDomes, Ecophys.Photosynthesis, Ecophys.Growth, PlantSimEngine],
    authors="Alejandro Morales <alejandro.moralessierra@wur.nl> and contributors",
    repo="https://github.com/VirtualPlantLab/VPLDocs/blob/{commit}{path}#{line}",
    sitename="Virtual Plant Laboratory",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        edit_link="master",
        assets=String[],
        collapselevel = 1,
        footer = nothing,
        size_threshold = nothing
    ),
    pages=[
        "Virtual Plant Laboratory" => "index.md",
        "Manual" => [
            "Julia" => ["Julia basic concepts" => "manual/Julia/Julia.md",
                        "Multiple dispatch and composition" => "manual/Julia/Objects.md",
                        "Modules and files" => "manual/Julia/Modules.md"
                        ],
            "Dynamic graph creation and manipulation" => "manual/Graphs.md",
            "Geometry primitives" => "manual/Geometry/Primitives.md",
            "Turtle geometry and scenes" => "manual/Geometry/Turtle.md",
            "Ray tracing" => "manual/Raytracer.md",
            "3D visualization" => "manual/Visualization.md"
        ],
        "Tutorials" => ["Intro" => "tutorials/intro_tut.md",
            "Getting started with VPL" =>
            ["Algae growth" => "tutorials/getting_started/algae.md",
            "The Koch snowflake" => "tutorials/getting_started/snowflakes.md"],
            "From tree to forest" =>
            ["Tree" => "tutorials/from_tree_forest/tree.md",
            "Forest" => "tutorials/from_tree_forest/forest.md",
            "Growth forest" => "tutorials/from_tree_forest/growthforest.md",
            "Ray-traced forest" => "tutorials/from_tree_forest/raytracedforest.md"],
            "More on rules and queries" =>
            ["Context sensitive rules" => "tutorials/more_rules_queries/context.md",
            "Relational queries" => "tutorials/more_rules_queries/relationalqueries.md"]
        ],
        "How-to guides" => [
            "Setting up a grid cloner" => "howto/GridCloner.md",
            "Messages in scenes" => "howto/Message.md",
            "Multiple materials/colors" => "howto/Materials.md",
            "Advanced traversal" => "howto/Traversal.md",
            "Absolute coordinates" => "howto/Coordinates.md",
            "Creating light sources" => "howto/LightSources.md",
            "Using the slicer" => "howto/Slicer.md"
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
                "Photosynthesis API" => "VPLVerse/Ecophys/photosynthesis.md",
                "Growth API" => "VPLVerse/Ecophys/growth.md"
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
            "Package and Environment Management for VPL" => "developers/use&dev_packages.md"
            "Styling protocol" => "developers/style.md"
        ]
    ],
)

deploydocs(;
    repo="github.com/VirtualPlantLab/VPLDocs",
    devbranch="master",
)
