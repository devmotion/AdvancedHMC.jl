using Test, AdvancedHMC
include("common.jl")

ϵ = 0.01
lf = Leapfrog(ϵ)

θ_init = randn(D)
h = Hamiltonian(UnitEuclideanMetric(θ_init), logπ, ∂logπ∂θ)
r_init = AdvancedHMC.rand_momentum(h)

n_steps = 10

@testset "step() against steps()" begin
    θ1, r1 = copy(θ_init), copy(r_init)

    @time for i = 1:n_steps
        θ1, r1, _ = AdvancedHMC.step(lf, h, θ1, r1)
    end

    @time θ2, r2, _ = AdvancedHMC.steps(lf, h, θ_init, r_init, n_steps)

    @test θ1 ≈ θ2 atol=DETATOL
    @test r1 ≈ r2 atol=DETATOL
end

using Turing: Inference
@testset "steps() against Turing.Inference._leapfrog()" begin
    @time θ1, r1, _ = Inference._leapfrog(θ_init, r_init, n_steps, ϵ, x -> (nothing, ∂logπ∂θ(x)))
    @time θ2, r2, _ = AdvancedHMC.steps(lf, h, θ_init, r_init, n_steps)

    @test θ1 ≈ θ2 atol=DETATOL
    @test r1 ≈ r2 atol=DETATOL
end