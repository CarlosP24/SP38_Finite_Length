using CairoMakie, JLD2, Parameters, Revise

includet("plot_functions.jl")
##

function ξM_a(model)
    Rav = model.R - model.w/2
    RLP = model.R + model.d/2
    α = model.α
    μt = model.μ
    g = model.g
    Δ = model.Δ0
    τΓ = model.τΓ
    #Δ = Δ0 * τΓ
    μBΦ0 = 119.6941183     
    m = 0.023 / 76.1996
    VZ(ϕ) = 0.5 * ϕ * (1/(2*m*Rav^2) + α/Rav)
    μ(ϕ) = μt - α/(2*Rav) - (1 + ϕ^2)/(8 * m * Rav^2)
    ϕ(Φ) = 3 - (Rav^2/RLP^2) * Φ
    VZg(Φ) = 0.5 * g * μBΦ0 * Φ /(π * RLP^2)
    #ξM(Φ) = sqrt((VZg(Φ) + VZ(ϕ(Φ)))^2 + m * α^2 * (m * α^2 + 2*μ(ϕ(Φ))))/(m * Δ * α)
    Δin(Φ) = (VZg(Φ) + VZ(ϕ(Φ)))^2 - Δ^2
    ξM(Φ) = Δin(Φ)>=0 ? sqrt(Δin(Φ)) / (m * Δ * α) :  NaN
    # ξM(Φ) = (VZ(ϕ(Φ)) + VZg(Φ))/(m*Δ*α)
    return ξM
end

function plot_length(path, mod, n; dlim = 2e-2)
    fig = Figure()
    indir = "$path/$mod/semi"
    # Numerical length
    
    fdata = build_data("$(indir)_uc_$(n).jld2")
    fdata_length = build_data_length("$(indir)_length_uc_$(n).jld2")

    @unpack Φrng, ωrng, LDOS, Φa, Φb, model = fdata
    @unpack Lms = fdata_length
    midω = ceil(Int, length(ωrng)/2)
    Ls0 = Lms[:, midω ]
    LDOS0 = LDOS[0][:, midω]
    ξM = Ls0 .* (LDOS0 .> dlim)
    ξM[ξM .== 0.0] .= NaN
    ξM = vec(ξM)

    ξ_M = ξM_a(model)

    ax = Axis(fig[1, 1]; backgroundcolor = (:white, 0),)
    lines!(ax, Φrng, ξM; color = :navyblue)
    lines!(ax, Φrng, ξ_M.(Φrng); color = :red)
    return fig
end

mod = "TCM_20"
fig = plot_length("Output", mod, 3)
fig