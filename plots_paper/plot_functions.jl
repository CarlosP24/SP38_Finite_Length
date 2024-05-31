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

@with_kw struct formated_data_length
    Φrng = nothing
    Lms = nothing
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

function build_data_length(indir)
    data = load(indir)
    Φrng = data["Φrng"]
    Lms = data["Lms"]
    return formated_data_length(; Φrng, Lms)
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
    vlines!(ax, [nforced - 0.5, nforced + 0.5]; color = :white, linestyle = :dashdot)
    return ax
end

function plot_length(pos, fdata, fdata_length; dlim = 1)
    @unpack Lms = fdata_length 
    @unpack Φrng, ωrng, LDOS, Φa, Φb = fdata 

    LDOS_MZM = sum(values(LDOS)) .> dlim
    ξM = sum(Lms .* LDOS_MZM, dims = 2) 

    ξM[ξM .== 0.0] .= NaN
    ξM = vec(ξM)
    notNaN_ξM = .!isnan.(ξM)
    ξMax = ξM[findfirst(notNaN_ξM)]
    ξMin = minimum(ξM[findall(notNaN_ξM)])
    ax = Axis(pos; backgroundcolor = (:white, 0), yaxisposition = :right, )
    lines!(ax, Φrng, ξM; color = :white, linestyle = :dash, linewidth = 3)
    xlims!(ax, (Φa, Φb))
    ylims!(ax, (-ξMax, ξMax))
    return ax
end