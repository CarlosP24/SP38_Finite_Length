using CairoMakie, JLD2, Parameters, Revise

includet("plot_functions.jl")

function plot_finite(path, mod, Lleft, Lright)
    fig = Figure(size = (1100, 250 * 2), font = "CMU Serif Roman", fontsize = 20)

    col = 1
    for L in [Lleft, Lright]
        indir = "$path/$mod/L=$L.jld2"
        fdata = build_data(indir)

        ax = plot_LDOS(fig[1, col], fdata; colorrange = (3e-4, 2e-2))
        col != 1 && hideydecorations!(ax; ticks = false) 
        hidexdecorations!(ax, ticks = false)
        ax = plot_LDOS_mJ0(fig[2, col], fdata; colorrange = (3e-4, 2e-2))
        col != 1 && hideydecorations!(ax; ticks = false) 
        col += 1
        nforced = 1
        indir1 = replace(indir, ".jld2" => "_uc_$(nforced).jld2")
        fdata = build_data(indir1)
        ax = plot_LDOS_uc(fig[1, col], fdata, nforced; colorrange = (1e-4, 3e-3))
        hideydecorations!(ax; ticks = false)
        hidexdecorations!(ax, ticks = false)

        nforced = 3
        indir1 = replace(indir, ".jld2" => "_uc_$(nforced).jld2")
        fdata = build_data(indir1)
        ax = plot_LDOS_uc(fig[2, col], fdata, nforced; colorrange = (1e-4, 3e-3))
        hideydecorations!(ax; ticks = false)
        col += 1
    end

    cbar = (; colormap = :thermal, label = L"$$ LDOS (arb. units)", limits = (0, 1),  ticklabelsvisible = true, ticks = [0,1], labelpadding = -10,  width = 15, ticksize = 2, ticklabelpad = 5, labelsize = 16,)

    Colorbar(fig[1, 5]; cbar...)
    Colorbar(fig[2, 5]; cbar...)

    Label(fig[1, 1:2, Top()], L"$L = %$(Lleft*5)$ nm", padding = (0, 0, 5, 0), fontsize = 20)
    Label(fig[1, 3:4, Top()], L"$L = %$(Lright*5)$ nm", padding = (0, 0, 5, 0), fontsize = 20)

    style = (font = "CMU Serif Bold", fontsize = 20)
    Label(fig[1, 1, TopLeft()], "a",  padding = (-40, 0, -50, 0); style...)
    style = (font = "CMU Serif Bold", fontsize = 20)
    Label(fig[1, 2, TopLeft()], "b",  padding = (-15, 0, -50, 0); style...)
    Label(fig[2, 1, TopLeft()], "c",  padding = (-40, 0, -25, 0); style...)
    style = (font = "CMU Serif Bold", fontsize = 20)
    Label(fig[2, 2, TopLeft()], "d",  padding = (-15, 0, -25, 0); style...)

    Label(fig[1, 3, TopLeft()], "e",  padding = (-15, 0, -50, 0); style...)
    style = (font = "CMU Serif Bold", fontsize = 20)
    Label(fig[1, 4, TopLeft()], "f",  padding = (-15, 0, -50, 0); style...)
    Label(fig[2, 3, TopLeft()], "g",  padding = (-15, 0, -25, 0); style...)
    style = (font = "CMU Serif Bold", fontsize = 20)
    Label(fig[2, 4, TopLeft()], "h",  padding = (-15, 0, -25, 0); style...)

    rowgap!(fig.layout, 1, 10)
    colgap!(fig.layout, 4, 5)
    [colgap!(fig.layout, i, 15) for i in 1:3]
    return fig

end

fig = plot_finite("Output", "TCM_20", 50, 200)
outpath = "/Users/carlospaya/Dropbox/141. Full-shell Majorana oscillations/Paper Draft/Figure proposals"
save(joinpath(outpath, "Fig_TCM_20_finite.pdf"), fig)
fig