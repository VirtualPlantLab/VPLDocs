# Temporary CI driver, deliberately kept outside PR29.
using Pkg
using SHA
using TOML

length(ARGS) == 2 || error("Usage: source_preflight.jl environment|build OUTPUT")
mode, output_directory = ARGS
mode in ("environment", "build") || error("Unknown mode: $mode")
repository = dirname(@__DIR__)
pb_repository = joinpath(dirname(repository), "PlantBiophysics")
pb_commit = readchomp(`git -C $pb_repository rev-parse HEAD`)
pb_commit == ENV["PB_CANDIDATE"] || error("Wrong PlantBiophysics candidate")
isempty(readchomp(`git -C $pb_repository status --porcelain --untracked-files=no`)) ||
    error("PlantBiophysics source is modified")
realpath(Base.active_project()) == realpath(joinpath(@__DIR__, "Project.toml")) ||
    error("Expected the VPLDocs docs environment")
package_records = Dict{String,Any}()
dependencies = Pkg.dependencies()
for (name, expected_version) in (
    "PlantBiophysics" => v"0.18.0",
    "PlantSimEngine" => v"0.15.0",
    "PlantGeom" => v"0.20.0",
)
    info = only(filter(info -> info.name == name, collect(values(dependencies))))
    info.version == expected_version || error("Unexpected $name version: $(info.version)")
    if name == "PlantBiophysics"
        info.is_tracking_path || error("PlantBiophysics must use the candidate checkout")
        realpath(info.source) == realpath(pb_repository) || error("Wrong PlantBiophysics path")
    else
        info.is_tracking_registry || error("$name must come from General")
        isnothing(info.tree_hash) && error("$name lacks a registry tree hash")
    end
    package_records[name] = Dict(
        "version" => string(info.version),
        "path" => info.source,
        "registered" => info.is_tracking_registry,
        "tree_hash" => isnothing(info.tree_hash) ? "checkout" : string(info.tree_hash),
    )
end

if mode == "environment"
    mkpath(output_directory)
    cp(Base.active_project(), joinpath(output_directory, "Project.toml"); force=true)
    cp(Pkg.Types.Context().env.manifest_file, joinpath(output_directory, "Manifest.toml"); force=true)
    open(joinpath(output_directory, "source.toml"), "w") do io
        TOML.print(io, Dict(
            "scope" => "Source preflight only; not registry acceptance; no deployment",
            "vpldocs_candidate" => ENV["VPL_CANDIDATE"],
            "validation_commit" => readchomp(`git -C $repository rev-parse HEAD`),
            "plantbiophysics_candidate" => pb_commit,
            "julia_version" => string(VERSION),
            "docs_make_sha256" => bytes2hex(sha256(read(joinpath(@__DIR__, "make.jl")))),
            "packages" => package_records,
        ); sorted=true)
    end
else
    make_path = joinpath(@__DIR__, "make.jl")
    source = read(make_path, String)
    # Preserve the complete original makedocs call, including doctest policy,
    # page list and rendering settings. Exclude only its exact final publish call.
    deployment = "\ndeploydocs(;\n    repo=\"github.com/VirtualPlantLab/VPLDocs\",\n    devbranch=\"master\",\n)\n"
    endswith(source, deployment) || error("Unexpected docs deployment boundary")
    build_source = chop(source; tail=length(deployment))
    @info "Building source preflight; final deploydocs call excluded" pb_commit
    Base.include_string(Main, build_source, make_path)
end
