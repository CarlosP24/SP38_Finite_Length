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

