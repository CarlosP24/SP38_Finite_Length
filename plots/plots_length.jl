using Revise, CairoMakie, JLD2
includet("plot_functions.jl")

function plot_LDOS_length(mod, L, cmax; path = "Output")
    if L == 0
        subdir = "semi"
    else
        subdir = "L=$(L)"
    end

    dir = "$(path)/$(mod)/$(subdir)"

    data_LDOS = load("$(dir).jld2")
    data_Length = load("$(dir)_length.jld2")

    cbar = (; colormap = :thermal, label = L"$$ LDOS (arb. units)", limits = (0, 1),  ticklabelsvisible = true, ticks = [0,1], labelpadding = -5,  width = 15, ticksize = 2, ticklabelpad = 5, labelsize = 16)

    fig = Figure(size = (600, 500), fontsize = 20)

    ax, _ = plot_LDOS(fig[1, 1], data_LDOS; colorrange = (5e-4, cmax),)
    Colorbar(fig[1, 2]; cbar...) 

    hidexdecorations!(ax; ticks = false)
    Δ0 = data_Length["model"].Δ0
    yticks = ([-Δ0, 0, Δ0], [L"-\Delta_0", "0", L"\Delta_0"]) 
    ax = Axis(fig[2, 1]; xlabel = L"\Phi / \Phi_0", ylabel = L"$\omega$", yticks)
    Φrng = data_Length["Φrng"]
    ωrng = real.(data_LDOS["ωrng"])
    ξs = data_Length["Lms"] .* data_Length["model"].a0

    mξ, Mξ = minimum(ξs), maximum(ξs)
    Mξ /= 1e1
    lmξ, lMξ = round(Int64, log10(mξ)), round(Int64, log10(Mξ)) 

    heatmap!(ax, Φrng, ωrng, ξs; colormap = :viridis, colorrange = (mξ, Mξ))

    cbar = (; colormap = :viridis, label = L"$\xi_M", limits = (mξ, Mξ),  ticklabelsvisible = true, ticks = ([mξ, Mξ], [L"10^{%$(lmξ)}", L"10^{%$(lMξ)}"]),labelpadding = -20,  width = 15, ticksize = 2, ticklabelpad = 5, labelsize = 16)
    Colorbar(fig[2, 2]; cbar...) 

    Φrng = data_LDOS["Φrng"]
    Φlims = (first(Φrng), last(Φrng))
    xlims!(ax, Φlims)

    L = L*data_Length["model"].a0
    
    Label(fig[1, 1, Top()], ifelse(L == 0, "semi-infinite", L"$L = %$(L)$ nm"))

    colgap!(fig.layout, 1, 5)
    return fig
end

mod = "TCM_small_20"
L = 0
cmax = 5e-2
fig = plot_LDOS_length(mod, L, cmax)
figdir = "Figures/$(mod)"
mkpath(figdir)
save("$(figdir)/LDOS_length_L$(L).pdf", fig)
fig

##
function plot_MZM_ξ(mod, L; path = "Output")
    if L == 0
        subdir = "semi"
    else
        subdir = "L=$(L)"
    end

    dir = "$(path)/$(mod)/$(subdir)"
    data_LDOS = load("$(dir).jld2")
    data_Length = load("$(dir)_length.jld2")

    Φrng0 = data_LDOS["Φrng"]
    ωrng = real.(data_LDOS["ωrng"])
    LDOS0 = data_LDOS["LDOS"]
    length = data_Length["Lms"]
    a0 = data_Length["model"].a0

    ΦrngL = data_Length["Φrng"]
    Φa, Φb = [findmin(abs.(Φrng0 .- Φ))[2] for Φ in [first(ΦrngL), last(ΦrngL)]]

    Φrng = Φrng0[Φa:Φb]
    LDOS = LDOS0[0][Φa:Φb, :]

    MZM = findall(LDOS .> 0.1)

    fig = Figure()
    ax = Axis(fig[1, 1]; )
    heatmap!(ax, Φrng0, ωrng, sum(values(LDOS0)); colormap = :thermal, colorrange = (1e-3, 1e-2), lowclip = :black  )
    
    ax = Axis(fig[2, 1]; yscale = log10)
    lines!(ax, ΦrngL, length[:, 101], color = :navyblue)
    xlims!(ax, (first(Φrng0), last(Φrng0)))
    return fig, length, MZM
end

mod = "HCA_small"
L = 0
fig, length, MZM = plot_MZM_ξ(mod, L)
fig