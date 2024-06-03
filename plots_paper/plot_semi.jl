using CairoMakie, JLD2, Parameters, Revise

includet("plot_functions.jl")

## 
function plot_semi_inf(path, mod)
    fig = Figure(size = (1100, 300), font = "CMU Serif Roman", fontsize = 20)

    # Full LDOS
    indir = "$path/$mod/semi.jld2"
    fdata = build_data(indir)
    
    ax = plot_LDOS(fig[2, 1], fdata; colorrange = (3e-4, 2e-2))
    
    # n = 1 
    nforced = 1
    indir1 = replace(indir, ".jld2" => "_uc_$(nforced).jld2")
    fdata = build_data(indir1)

    ax = plot_LDOS_uc(fig[2, 2], fdata, nforced; colorrange = (1e-4, 3e-3))
    hideydecorations!(ax; ticks = false)

    # Length
    fdata_length = build_data_length("$path/$mod/semi_uc_1.jld2")
    ax, ξMax, ξMin = plot_length(fig[1, 2], fdata, fdata_length; dlim = 2e-2,colorrange = (log10(50), log10(160)))

    # n = 3
    nforced = 3
    indir1 = replace(indir, ".jld2" => "_uc_$(nforced).jld2")
    fdata = build_data(indir1)

    ax = plot_LDOS_uc(fig[2, 3], fdata, nforced; colorrange = (1e-4, 3e-3))
    hideydecorations!(ax; ticks = false) 

    # Length
    fdata_length = build_data_length("$path/$mod/semi_length_uc_3.jld2")
    ax, ξMax, ξMin = plot_length(fig[1, 3], fdata, fdata_length; dlim = 2e-2, colorrange = (log10(50), log10(170)))


    ξdown = round(Int, round(ξMin, digits = -1)*5)
    ξup = round(Int, round(ξMax, digits = -1)*5)
    #tick2 = 0.25
    #ξ2 = round(Int, ξdown + (ξup - ξdown)*tick2)

    cbar = (; colormap = :thermal, label = L"$$ LDOS (arb. units)", limits = (0, 1),  ticklabelsvisible = true, ticks = [0,1], labelpadding = -10,  width = 15, ticksize = 2, ticklabelpad = 5, labelsize = 16,)

    Colorbar(fig[2, 4]; cbar...)

    cbar = (; colormap = :RdYlGn_9, label = L"$\xi_M$ (nm)", limits = (0, 1),  ticklabelsvisible = true, ticks = ([0,  1], [L"%$(ξdown)", L"$\infty$"]), labelpadding = -30,  width = 15, ticksize = 2, ticklabelpad = 5, labelsize = 16,)

    Colorbar(fig[2, 5]; cbar...)


    style = (font = "CMU Serif Bold", fontsize = 20)
    Label(fig[1, 1, TopLeft()], "a",  padding = (-40, 0, -25, 0); style...)
    Label(fig[1, 2, TopLeft()], "b",  padding = (-10, 0, -25, 0); style...)
    Label(fig[1, 3, TopLeft()], "c",  padding = (-10, 0, -25, 0); style...)

    colgap!(fig.layout, 1, 10)
    colgap!(fig.layout, 2, 10)
    colgap!(fig.layout, 3, 5)
    rowgap!(fig.layout, 1, 0)

    rowsize!(fig.layout, 1, Relative(0.1))

    return fig
end

mod = "TCM_20"
fig = plot_semi_inf("Output", mod)
outpath = "/Users/carlospaya/Dropbox/141. Full-shell Majorana oscillations/Manuscript/Figure proposals"
save(joinpath(outpath, "Fig_TCM_20.pdf"), fig)
fig

##
mod = "SCM_70"
fig = plot_semi_inf("Output", mod)
save(joinpath(outpath, "Fig_SCM_70.pdf"), fig)
fig