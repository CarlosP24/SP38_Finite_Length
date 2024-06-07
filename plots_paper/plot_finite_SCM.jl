using CairoMakie, JLD2, Parameters, Revise

includet("plot_functions.jl")

function plot_finite_SCM(path, mod, Lleft, Lright; colorrange_full = (3e-3, 2e-1), colorrange_0 = (3e-3, 2e-1), colorrange_n = (2e-4, 3e-2))
    fig = Figure(size = (1100, 250 * 2), font = "CMU Serif Roman", fontsize = 16)

    col = 1
    for L in [Lleft, Lright]
        indir = "$path/$mod/L=$L.jld2"
        fdata = build_data(indir)

        ax = plot_LDOS(fig[2, col], fdata; colorrange = colorrange_full)
        pan_label(fig[2, col], "Total"; width = Relative(0.2), height = Relative(0.1), fontsize = 15, textpadding = (6, 0, 10, 0))
        col != 1 && hideydecorations!(ax; ticks = false) 
        hidexdecorations!(ax, ticks = false)
        ax = plot_LDOS_mJ0(fig[3, col], fdata; colorrange = colorrange_0 )
        pan_label(fig[3, col], L"Lowest $|m_J|$", fontsize = 14, halign = 0.9, width = Relative(0.35), height = Relative(0.12), textpadding = (3, 0, 0, 2))
        col != 1 && hideydecorations!(ax; ticks = false) 
        col += 1
        nforced = 1
        indir1 = replace(indir, ".jld2" => "_uc_$(nforced).jld2")
        fdata = build_data(indir1)
        @unpack Φa, Δ0 = fdata
        ax = plot_LDOS_uc(fig[2, col], fdata, nforced; colorrange = colorrange_n)
        ax.xticks = range(-29, 31; step = 10)
        pan_label(fig[2, col], "Fixed fluxoid", halign = 0.2, trans = 0.7, width = Relative(0.43), height = Relative(0.1), fontsize = 15, textpadding = (6, 0, 10, 0))
        hideydecorations!(ax; ticks = false)
        hidexdecorations!(ax, ticks = false, minorticks = false)
        text!(ax, Φa + 8, Δ0*0.3; text = L"n = %$(nforced)", align = (:center, :center), color = :white, fontsize = 15)
        text!(ax, Φa + 8, -Δ0*0.3 ; text = L"m_J = 0", align = (:center, :center), color = :white, fontsize = 15)

        nforced = 3
        indir1 = replace(indir, ".jld2" => "_uc_$(nforced).jld2")
        fdata = build_data(indir1)
        @unpack Φa, Δ0 = fdata
        ax = plot_LDOS_uc(fig[3, col], fdata, nforced; colorrange = colorrange_n)
        ax.xticks = range(-29, 31; step = 10)
        pan_label(fig[3, col], "Fixed fluxoid", halign = 0.2, trans = 0.7, width = Relative(0.43), height = Relative(0.1), fontsize = 15, textpadding = (6, 0, 10, 0))
        hideydecorations!(ax; ticks = false)
        text!(ax, Φa + 8, Δ0*0.3; text = L"n = %$(nforced)", align = (:center, :center), color = :white, fontsize = 15)
        text!(ax, Φa + 8, -Δ0*0.3 ; text = L"m_J = 0", align = (:center, :center), color = :white, fontsize = 15)
        col += 1
    end

    ax = Axis(fig[1, 1:2])
    hlines!(ax, 0; color = :black,)
    hidedecorations!(ax)
    hidespines!(ax)
    ax = Axis(fig[1, 3:4])
    hlines!(ax, 0; color = :black,)
    hidedecorations!(ax)
    hidespines!(ax)
    

    cbar = (; colormap = :thermal, label = L"$$ LDOS (arb. units)", limits = (0, 1),  ticklabelsvisible = true, ticks = [0,1], labelpadding = -10,  width = 15, ticksize = 2, ticklabelpad = 5, labelsize = 16,)

    Colorbar(fig[2, 5]; cbar...)
    Colorbar(fig[3, 5]; cbar...)

    Label(fig[1, 1:2, Top()], L"$L = %$(Lleft*5)$ nm", padding = (0, 0, 5, 0), fontsize = 20)
    Label(fig[1, 3:4, Top()], L"$L = %$(Lright*5)$ nm", padding = (0, 0, 5, 0), fontsize = 20)

    style = (font = "CMU Serif Bold", fontsize = 20)
    Label(fig[2, 1, TopLeft()], "a",  padding = (-40, 0, -50, 0); style...)
    style = (font = "CMU Serif Bold", fontsize = 20)
    Label(fig[2, 2, TopLeft()], "c",  padding = (-15, 0, -50, 0); style...)
    Label(fig[3, 1, TopLeft()], "b",  padding = (-40, 0, -25, 0); style...)
    style = (font = "CMU Serif Bold", fontsize = 20)
    Label(fig[3, 2, TopLeft()], "d",  padding = (-15, 0, -25, 0); style...)

    Label(fig[2, 3, TopLeft()], "e",  padding = (-15, 0, -50, 0); style...)
    style = (font = "CMU Serif Bold", fontsize = 20)
    Label(fig[2, 4, TopLeft()], "g",  padding = (-15, 0, -50, 0); style...)
    Label(fig[3, 3, TopLeft()], "f",  padding = (-15, 0, -25, 0); style...)
    style = (font = "CMU Serif Bold", fontsize = 20)
    Label(fig[3, 4, TopLeft()], "h",  padding = (-15, 0, -25, 0); style...)

    rowgap!(fig.layout, 2, 10)
    colgap!(fig.layout, 4, 5)
    [colgap!(fig.layout, i, 15) for i in 1:3]
    rowsize!(fig.layout, 1, Relative(0.0001))
    return fig

end

##
fig = plot_finite_SCM("Output", "SCM_70", 200, 400;)
outpath = "/Users/carlospaya/Dropbox/141. Full-shell Majorana oscillations/Material/Figure proposals"
save(joinpath(outpath, "Fig_SCM_70_finite.pdf"), fig)
fig

