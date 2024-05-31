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
        ld = try 
            ρ(ω; ω = ω, Φ = Φ, Z = Z)
        catch
            0.0
        end
        return ld
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

function calc_length(g, Φrng, ωrng; ω = 0.0 + 1e-4im, Z = 0, minabs = 1e-5)
    pts = Iterators.product(Φrng, ωrng)
    Lm = @showprogress pmap(pts) do pt
        Φ, ω = pt
        return maximum(Quantica.decay_lengths(g, ω, minabs; Φ = Φ, Z = Z))
    end
    Lmvec = reshape(Lm, size(pts)...) 
    return Lmvec
end