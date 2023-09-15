using VPLDocs
using Test
using Aqua

@testset "VPLDocs.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(VPLDocs; ambiguities = false,)
    end
    # Write your tests here.
end
