using CairoMakie, JLD2, Parameters, Revise

includet("plot_functions.jl")

## 
function plot_semi_inf(path, mod)
    fig = Figure(size = (1100, 250), font = "CMU Serif Roman", fontsize = 20)

    # Full LDOS
    indir = "$path/$mod/semi.jld2"
    fdata = build_data(indir)
    
    ax = plot_LDOS(fig[1, 1], fdata; colorrange = (5e-4, 5e-2))
    
    # n = 1 
    nforced = 1
    indir1 = replace(indir, ".jld2" => "_uc_$(nforced).jld2")
    fdata = build_data(indir1)

    ax = plot_LDOS_uc(fig[1, 2], fdata, nforced; colorrange = (2.5e-5, 5e-3))
    hideydecorations!(ax; ticks = false)
    # n = 3
    nforced = 3
    indir1 = replace(indir, ".jld2" => "_uc_$(nforced).jld2")
    fdata = build_data(indir1)

    ax = plot_LDOS_uc(fig[1, 3], fdata, nforced; colorrange = (2.5e-5, 5e-3))
    hideydecorations!(ax; ticks = false)

    cbar = (; colormap = :thermal, label = L"$$ LDOS (arb. units)", limits = (0, 1),  ticklabelsvisible = true, ticks = [0,1], labelpadding = -5,  width = 15, ticksize = 2, ticklabelpad = 5, labelsize = 12)

    Colorbar(fig[1, 4]; cbar...)

    style = (font = "CMU Serif Bold", fontsize = 20)
    Label(fig[1, 1, TopLeft()], "a",  padding = (-40, 0, -25, 0); style...)
    Label(fig[1, 2, TopLeft()], "b",  padding = (-20, 0, -25, 0); style...)
    Label(fig[1, 3, TopLeft()], "c",  padding = (-20, 0, -25, 0); style...)

    colgap!(fig.layout, 1, 15)
    colgap!(fig.layout, 2, 15)
    colgap!(fig.layout, 3, 5)

    return fig
end

mod = "TCM_20"
fdata = plot_semi_inf("Output", mod)
