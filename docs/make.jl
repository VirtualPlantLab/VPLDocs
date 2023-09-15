using VPLDocs
using Documenter

DocMeta.setdocmeta!(VPLDocs, :DocTestSetup, :(using VPLDocs); recursive=true)

makedocs(;
    modules=[VPLDocs],
    authors="Alejandro Morales Sierra <alejandro.moralessierra@wur.nl> and contributors",
    repo="https://github.com/AleMorales/VPLDocs.jl/blob/{commit}{path}#{line}",
    sitename="VPLDocs.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://AleMorales.github.io/VPLDocs.jl",
        edit_link="master",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/AleMorales/VPLDocs.jl",
    devbranch="master",
)
