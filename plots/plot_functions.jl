
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
    return ax, ωrng
end