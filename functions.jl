# Get Greens
function get_greens_semi(hSC, params)
    return hSC |> greenfunction(GS.Schur(boundary = 0))
    
end

function get_greens_finite(hSC, params)
    @unpack L = params
    return hSC |> attach(onsite(1e9 * σ0τz,), cells = (- L,)) |> greenfunction(GS.Schur(boundary = 0))
end

greens_dict = Dict(
    "semi" => get_greens_semi,
    "finite" => get_greens_finite,
)


# Calculations
function calc_ldos(ρ, Φs, ωs, Zs)
    pts = Iterators.product(Φs, ωs, Zs)
    LDOS = @showprogress pmap(pts) do pt
        Φ, ω, Z = pt 
        return ρ(ω; ω = ω, Φ = Φ, Z = Z)
    end
    LDOSarray = reshape(LDOS, size(pts)...)
    return Dict([Z => sum.(LDOSarray[:, :, i]) for (i, Z) in enumerate(Zs)])
end

function calc_ldos0(ρ, μrng, αrng, Φrng, Zs; ω = 0.0 + 1e-4im)
    pts = Iterators.product(μrng, αrng, Φrng, Zs)
    LDOS = @showprogress pmap(pts) do pt
        μ, α, Φ, Z = pt
        return ρ(ω; ω = ω, μ = μ, α = α, Φ = Φ, Z = Z)
    end
    LDOStensor = reshape(LDOS, size(pts)...)
    return Dict([Z => sum.(LDOStensor[:, :, :, i]) for (i, Z) in enumerate(Zs)])
end

function lead_decay_length(g::Quantica.GreenFunction, ω, minabs = 1e-5; params...)
    h = parent(g)                   # get the (Parametric)Hamiltonian from g
    Quantica.call!(h; params...)    # update the (Parametric)Hamiltonian with the params
    sf = g.solver.fsolver           # obtain the SchurFactorSolver that computes the AB pencil
    Quantica.update_LR!(sf)         # Ensure L and R matrices are updated after updating h
    Quantica.update_iG!(sf, ω)      # shift inverse G with ω
    A, B = Quantica.pencilAB!(sf)   # build the pecil
    λs = Quantica.eigvals!(A, B)    # extract the λs as geeraized eigenvales of the pencil
    filter!(λ -> 1 > abs(λ) > minabs, λs)   # get all the decaying λs
    λmin = maximum(abs, λs)         # get the least decaying λ
    Lm = -1/log(abs(λmin))          # extract decay length
    return Lm
end

function calc_length(g, Φrng, ωrng; ω = 0.0 + 1e-4im, Z = 0, minabs = 1e-5)
    pts = Iterators.product(Φrng, ωrng)
    Lm = @showprogress pmap(pts) do pt
        Φ, ω = pt
        return lead_decay_length(g, ω, minabs = minabs; ω = ω, Φ = Φ, Z = Z)
    end
    Lmvec = reshape(Lm, size(Φrng)...) 
    return Lmvec
end
