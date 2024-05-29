using CairoMakie, JLD2

function plot_prop(mod, L; path = "Output", colormap = cgrad(:thermal)[10:end], colorrange = (5e-4, 5e-2))
    fig = Figure(size = (800, 800), fontsize = 20)
    xlabel = L"\Phi / \Phi_0"
    ylabel = L"\omega"

    if L == 0
        gs = "semi"
        subdir = "semi"
    else
        gs = "finite"
        subdir = "L=$(L)"
    end

    # Full LDOS
    indir = "$path/$(mod)/$(subdir).jld2"
    data = load(indir)
    Φrng = data["Φrng"]
    ωrng = real.(data["ωrng"])
    LDOS = data["LDOS"]
    Δ0 = data["model"].Δ0
    Φa, Φb = first(Φrng), last(Φrng)
    xticks = range(round(Int, Φa), round(Int, Φb))
    yticks = ([-Δ0, 0, Δ0], [L"-\Delta_0", "0", L"\Delta_0"]) 

    ax = Axis(fig[1, 1]; xlabel, ylabel, xticks, yticks)
    heatmap!(ax, Φrng, ωrng, sum(values(LDOS)); colormap, colorrange, lowclip = :black)
    xlims!(ax, (Φa, Φb))
    hidexdecorations!(ax; ticks = false)

    # mJ = 0
    lobe = round.(Int, Φrng)
    ax = Axis(fig[2, 1]; xlabel, ylabel, xticks, yticks)
    heatmap!(ax, Φrng, ωrng, LDOS[0] .+ LDOS[-1].*iseven.(lobe); colormap, colorrange, lowclip = :black)
    xlims!(ax, (Φa, Φb))
    [text!(ax, x, -Δ0; text = ifelse(iseven(x), L"m_J = \pm 1/2", L"m_J = 0"), align = ( ifelse(x == 0, :left, :center), :center), color = :white, fontsize = 15) for x in xticks]
    fig
end

mod = "HCA_70"
L = 0 
fig = plot_prop(mod, L)
fig