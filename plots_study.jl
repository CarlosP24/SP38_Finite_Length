using CairoMakie, JLD2

function plot_LDOS(pos, data; colorrange = (5e-4, 5e-2),  colormap = cgrad(:thermal)[10:end], ωs = nothing, vlines = nothing )
    xlabel = L"\Phi / \Phi_0"
    ylabel = L"\omega"
    Φrng = data["Φrng"]
    ωrng = real.(data["ωrng"])
    LDOS = data["LDOS"]
    Δ0 = data["model"].Δ0
    Φa, Φb = first(Φrng), last(Φrng)
    xticks = range(round(Int, Φa), round(Int, Φb))
    yticks = ([-Δ0, 0, Δ0], [L"-\Delta_0", "0", L"\Delta_0"]) 
    ax = Axis(pos; xlabel, ylabel, xticks, yticks)
    heatmap!(ax, Φrng, ωrng, sum(values(LDOS)); colormap, colorrange, lowclip = :black)
    xlims!(ax, (Φa, Φb))
    ωs !== nothing && hlines!(ax, ωs, color = :white, linewidth = 1, linestyle = :dash)
    vlines !== nothing && vlines!(ax, vlines, color = :white, linewidth = 1, linestyle = :dash)
    return ωrng
end


function plot_study(mod, L, cmax; path = "Output")
    # Load data
    if L == 0
        subdir = "semi"
    else
        subdir = "L=$(L)"
    end

    dir = "$(path)/$(mod)/$(subdir)"

    data = load("$(dir).jld2")
    data_uc1 = load("$(dir)_uc_1.jld2")
    data_uc2 = load("$(dir)_uc_2.jld2")

    cbar = (; colormap = :thermal, label = L"$$ LDOS (arb. units)", limits = (0, 1),  ticklabelsvisible = true, ticks = [0,1], labelpadding = -5,  width = 15, ticksize = 2, ticklabelpad = 5, labelsize = 16)

    fig = Figure(size = (600, 800), fontsize = 20)

    plot_LDOS(fig[2, 1], data_uc1; colorrange =  (1e-4, cmax * 1e-1), vlines = [0.5, 1.5]  )
    Colorbar(fig[2, 2]; cbar...)

    ωrng_z = plot_LDOS(fig[3, 1], data_uc2; colorrange =  (8e-4, cmax * 1e-1), vlines = [1.5, 2.5])
    Colorbar(fig[3, 2]; cbar...)

    plot_LDOS(fig[1, 1], data; colorrange = (5e-4, cmax), ωs = [first(ωrng_z), last(ωrng_z)])
    Colorbar(fig[1, 2]; cbar...)

    colgap!(fig.layout, 1, 5)

    style = (font = "CMU Serif Bold", fontsize = 20)
    Label(fig[1, 1, TopLeft()], "a",  padding = (-40, 0, -25, 0); style...)
    Label(fig[2, 1, TopLeft()], "b",  padding = (-40, 0, -25, 0); style...)
    Label(fig[2, 1, TopLeft()], L"n=1",  padding = (-40, 0, -100, 0); )
    Label(fig[2, 1, TopLeft()], L"m_J=0",  padding = (-40, 0, -300, 0); fontsize = 15)


    Label(fig[3, 1, TopLeft()], "c",  padding = (-40, 0, -25, 0); style... )
    Label(fig[3, 1, TopLeft()], L"n=2",  padding = (-40, 0, -100, 0); )
    Label(fig[3, 1, TopLeft()], L"m_J=\pm \frac{1}{2}",  padding = (-40, 0, -300, 0); fontsize = 15)

    L = L * data["model"].a0
    title = L == 0 ? L"$$ Semi-infinite" : L"Finite $L = %$(L)$nm"
    Label(fig[1, 1, Top()], title,  padding = (0, 0, 10, 0); )

    return fig
end


mod = "HCA"
L = 100
cmax = 5e-2
fig = plot_study(mod, L, cmax)
figdir = "Figures/$(mod)"
mkpath(figdir)
save("$(figdir)/LDOS_study_L$(L).pdf", fig)
fig

## 
mods = ["HCA", "HCA_small", "TCM_20", "TCM_small_20", "TCM_40", "TCM_small_40"]
Ls = [0, 100, 250, 500, 1000]

for mod in mods
    figdir = "Figures/$(mod)"
    mkpath(figdir)
    for L in Ls 
        fig = plot_study(mod, L, cmax)
        save("$(figdir)/LDOS_study_L$(L).pdf", fig)
    end
end

mods = ["SCM", "SCM_small"]
Ls = [0, 500, 1000, 1500, 2000] 
for mod in mods
    figdir = "Figures/$(mod)"
    mkpath(figdir)
    for L in Ls 
        fig = plot_study(mod, L, cmax)
        save("$(figdir)/LDOS_study_L$(L).pdf", fig)
    end
end

