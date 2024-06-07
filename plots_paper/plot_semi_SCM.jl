using CairoMakie, JLD2, Parameters, Revise

includet("plot_functions.jl")

##
function plot_semi_SCM(path, mod; colorrange_full = (3e-4, 2e-2), colorrange_n = (1e-4, 3e-3), colorrange_length = (log10(50), log10(170)), dlim = 2e-2,)
    fig = Figure(size = (1100, 300), font = "CMU Serif Roman", fontsize = 16)

    # Full LDOS
    indir = "$path/$mod/semi.jld2"
    fdata = build_data(indir)
    
    ax = plot_LDOS(fig[2, 1], fdata; colorrange = colorrange_full)
    pan_label(fig[2, 1], "Total"; width = Relative(0.17), height = Relative(0.1), fontsize = 15, textpadding = (6, 0, 10, 0))

    # n = 1 
    nforced = 1
    indir1 = replace(indir, ".jld2" => "_uc_$(nforced).jld2")
    fdata = build_data(indir1)
    @unpack Φa, Δ0 = fdata

    ax = plot_LDOS_uc(fig[2, 2], fdata, nforced; colorrange = colorrange_n, step = 10)
    hideydecorations!(ax; ticks = false)
    pan_label(fig[2, 2], "Fixed fluxoid"; halign = 0.9, width = Relative(0.35), height = Relative(0.1), fontsize = 15, textpadding = (6, 0, 10, 0))
    text!(ax, Φa + 6, Δ0*0.15 ; text = L"n = %$(nforced)", align = (:center, :center), color = :white, fontsize = 15)
    text!(ax, Φa + 6, -Δ0*0.15 ; text = L"m_J = 0", align = (:center, :center), color = :white, fontsize = 15)

    # Length
    fdata_length = build_data_length("$path/$mod/semi_length_uc_1.jld2")
    ax, ξMax, ξMin = plot_length_0(fig[1, 2], fdata, fdata_length; dlim, colorrange = colorrange_length)
    println("ξMax = $ξMax, ξMin = $ξMin")

    ξdown = round(Int, round(ξMin, digits = -1)*5)
    ξup = round(Int, round(ξMax, digits = -1)*5)
    eξup = ceil(Int, log10(ξup))
    cξup = round(Int, ξup/10^(eξup -1))
    eξdown = ceil(Int, log10(ξdown))
    eξs = range(eξdown, eξup-1; step = 1)

    ticks = [(log10(cξup * 10^(eξ-1)) - log10(ξdown))/(log10(ξup) - log10(ξdown)) for eξ in eξs]
    pushfirst!(ticks, 0)
    push!(ticks, 1)

    ticklabels = [L"%$(cξup) \cdot 10^{%$(eξ-1)}" for eξ in eξs]
    pushfirst!(ticklabels, L"%$(ξdown)")
    push!(ticklabels, L"%$(cξup) \cdot 10^{%$(eξup - 1)}")


    # n = 3
    nforced = 3
    indir1 = replace(indir, ".jld2" => "_uc_$(nforced).jld2")
    fdata = build_data(indir1)
    @unpack Φa, Δ0 = fdata

    ax = plot_LDOS_uc(fig[2, 3], fdata, nforced; colorrange = colorrange_n)
    ax.xticks = range(-27, 33; step = 10)
    pan_label(fig[2, 3], "Fixed fluxoid"; halign = 0.9, width = Relative(0.35), height = Relative(0.1), fontsize = 15, textpadding = (6, 0, 10, 0))
    hideydecorations!(ax; ticks = false, minorticks = false) 
    text!(ax, Φa + 6, Δ0*0.15 ; text = L"n = %$(nforced)", align = (:center, :center), color = :white, fontsize = 15)
    text!(ax, Φa + 6, -Δ0*0.15 ; text = L"m_J = 0", align = (:center, :center), color = :white, fontsize = 15)

    # Length
    fdata_length = build_data_length("$path/$mod/semi_length_uc_3.jld2")
    ax, ξMax, ξMin = plot_length_0(fig[1, 3], fdata, fdata_length; dlim, colorrange = colorrange_length)

    cbar = (; colormap = :thermal, label = L"$$ LDOS (arb. units)", limits = (0, 1),  ticklabelsvisible = true, ticks = [0,1], labelpadding = -10,  width = 15, ticksize = 2, ticklabelpad = 5, labelsize = 16,)

    Colorbar(fig[2, 4]; cbar...)

    cbar = (; colormap = :RdYlGn_9,  limits = (0, 1),  ticklabelsvisible = true, ticks = (ticks, ticklabels),  width = 15, ticksize = 2, ticklabelpad = 5, )

    Colorbar(fig[2, 5]; cbar...)


    style = (font = "CMU Serif Bold", fontsize = 20)
    Label(fig[1, 1, TopLeft()], "a",  padding = (-40, 0, -25, 0); style...)
    Label(fig[1, 2, TopLeft()], "b",  padding = (-10, 0, -25, 0); style...)
    Label(fig[1, 3, TopLeft()], "c",  padding = (-10, 0, -25, 0); style...)
    Label(fig[1, 5, Top()], L"$\xi_M$ (nm)",  padding = (0, 0, -15, 0); fontsize = 16)


    colgap!(fig.layout, 1, 10)
    colgap!(fig.layout, 2, 10)
    #colgap!(fig.layout, 3, 5)
    rowgap!(fig.layout, 1, 0)

    rowsize!(fig.layout, 1, Relative(0.1))

    return fig
end

##

mod = "SCM_70"
fig = plot_semi_SCM("Output", mod; colorrange_full = (3e-3, 2e-1), colorrange_n = (2e-4, 3e-2), colorrange_length = (log10(50), log10(170)), dlim = 2e-2)
outpath = "/Users/carlospaya/Dropbox/141. Full-shell Majorana oscillations/Material/Figure proposals"
save(joinpath(outpath, "Fig_$(mod).pdf"), fig)
fig

##
mod = "SCM_30"
fig = plot_semi_SCM("Local/Output", mod; colorrange_full = (3e-4, 2e-2), colorrange_n = (2e-4, 7e-3), colorrange_length = (log10(25), log10(100)), dlim = 3e-6)
outpath = "/Users/carlospaya/Dropbox/141. Full-shell Majorana oscillations/Material/Figure proposals"
save(joinpath(outpath, "Fig_$(mod).pdf"), fig)
fig

