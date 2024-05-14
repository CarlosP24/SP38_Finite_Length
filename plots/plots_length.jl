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

    ax = Axis(fig[2, 1]; xlabel = L"\Phi / \Phi_0", ylabel = L"$\xi_M$ (nm)",)
    Φrng = data_Length["Φrng"]
    ωrng = real.(data_LDOS["ωrng"])
    ξs = data_Length["Lms"] .* data_Length["model"].a0
    heatmap!(ax, Φrng, ωrng, ξs; colormap = :viridis)

    return fig
end

mod = "HCA"
L = 100
cmax = 5e-2
fig = plot_LDOS_length(mod, L, cmax)
figdir = "Figures/$(mod)"
mkpath(figdir)
save("$(figdir)/LDOS_length_L$(L).pdf", fig)
fig