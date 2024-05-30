@with_kw struct formated_data 
    xlabel = L"\Phi / \Phi_0"
    ylabel = L"\omega"
    data = nothing
    Φrng = nothing
    ωrng = nothing
    LDOS = nothing
    Δ0 = nothing
    Φa = nothing
    Φb = nothing
    xticks = nothing
    yticks = nothing
    ylabelpadding = -10
end

function build_data(indir)
    data = load(indir)
    Φrng = data["Φrng"]
    ωrng = real.(data["ωrng"])
    LDOS = data["LDOS"]
    Δ0 = data["model"].Δ0
    Φa, Φb = first(Φrng), last(Φrng)
    xticks = range(round(Int, Φa), round(Int, Φb))
    yticks = ([-Δ0, 0, Δ0], [L"-\Delta_0", "0", L"\Delta_0"]) 
    return formated_data(; data, Φrng, ωrng, LDOS, Δ0, Φa, Φb, xticks, yticks)
end

function plot_LDOS(pos, fdata; colormap = cgrad(:thermal)[10:end], colorrange = (5e-4, 5e-2))
    @unpack xlabel, ylabel, Φrng, ωrng, LDOS, Δ0, Φa, Φb, xticks, yticks, ylabelpadding = fdata
    ax = Axis(pos; xlabel, ylabel, xticks, yticks, ylabelpadding)
    heatmap!(ax, Φrng, ωrng, sum(values(LDOS)); colormap, colorrange, lowclip = :black, rasterize = 5)
    xlims!(ax, (Φa, Φb))
    return ax
end

function plot_LDOS_uc(pos, fdata, nforced; colormap = cgrad(:thermal)[10:end], colorrange = (5e-4, 5e-2))
    ax = plot_LDOS(pos, fdata; colormap, colorrange)
    @unpack Φa, Φb, Δ0 = fdata
    ax.xticks = range(round(Int, Φa)+1, round(Int, Φb)+1, step = 2)
    text!(ax, Φa + 1, Δ0*0.15 ; text = L"n = %$(nforced)", align = (:center, :center), color = :white, fontsize = 15)
    text!(ax, Φa + 1, -Δ0*0.15 ; text = L"m_J = 0", align = (:center, :center), color = :white, fontsize = 15)
    vlines!(ax, [nforced - 0.5, nforced + 0.5]; color = :white, linestyle = :dash)
    return ax
end