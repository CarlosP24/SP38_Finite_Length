using CairoMakie, JLD2, Parameters, Revise

includet("plot_functions.jl")

##
function plot_semi_SCM(path, mod; colorrange_full = (3e-4, 2e-2), colorrange_n = (1e-4, 3e-3), colorrange_length = (log10(50), log10(170)), dlim = 2e-2,)
    fig = Figure(size = (1100, 300), font = "CMU Serif Roman", fontsize = 20)

    # Full LDOS
    indir = "$path/$mod/semi.jld2"
    fdata = build_data(indir)
    
    ax = plot_LDOS(fig[1, 1], fdata; colorrange = colorrange_full)
    
    # n = 1 
    nforced = 1
    indir1 = replace(indir, ".jld2" => "_uc_$(nforced).jld2")
    fdata = build_data(indir1)

    ax = plot_LDOS_uc(fig[1, 2], fdata, nforced; colorrange = colorrange_n, step = 10)
    hideydecorations!(ax; ticks = false)

    nforced = 3
    indir1 = replace(indir, ".jld2" => "_uc_$(nforced).jld2")
    fdata = build_data(indir1)

    ax = plot_LDOS_uc(fig[1, 3], fdata, nforced; colorrange = colorrange_n, step = 10)
    hideydecorations!(ax; ticks = false) 


    cbar = (; colormap = :thermal, label = L"$$ LDOS (arb. units)", limits = (0, 1),  ticklabelsvisible = true, ticks = [0,1], labelpadding = -10,  width = 15, ticksize = 2, ticklabelpad = 5, labelsize = 16,)

    Colorbar(fig[1, 4]; cbar...)


    colgap!(fig.layout, 1, 10)
    colgap!(fig.layout, 2, 10)
    colgap!(fig.layout, 3, 5)

    return fig
end


mod = "SCM_70"
fig = plot_semi_SCM("Output", mod; colorrange_full = (3e-3, 2e-1), colorrange_n = (1e-4, 3e-2), colorrange_length = (log10(50), log10(170)), dlim = 2e-2)
outpath = "/Users/carlospaya/Dropbox/141. Full-shell Majorana oscillations/Manuscript/Figure proposals"
#save(joinpath(outpath, "Fig_TCM_20.pdf"), fig)
fig
