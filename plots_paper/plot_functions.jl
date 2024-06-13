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

function build_data_Φcut(indir, Φ1, Φ2)
    data = load(indir)
    Φrng = data["Φrng"]
    ind1 = findmin(abs.(Φrng .- Φ1))[2]
    ind2 = findmin(abs.(Φrng .- Φ2))[2]
    Φrng = Φrng[ind1:ind2]
    ωrng = real.(data["ωrng"])
    LDOS = data["LDOS"]
    LDOS = Dict(Z => LDOS[Z][ind1:ind2, :] for Z in keys(LDOS))
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
    ax = Axis(pos; xlabel, ylabel, xticks, yticks, ylabelpadding, xminorticksvisible = true)
    ax.xminorticks = range(Φa, Φb; step = 1)
    heatmap!(ax, Φrng, ωrng, sum(values(LDOS)); colormap, colorrange, lowclip = :black, rasterize = 5)
    xlims!(ax, (Φa, Φb))
    return ax
end

function plot_LDOS_uc(pos, fdata, nforced; colormap = cgrad(:thermal)[10:end], colorrange = (5e-4, 5e-2), step = 2)
    ax = plot_LDOS(pos, fdata; colormap, colorrange)
    @unpack Φa, Φb, Δ0 = fdata
    ax.xticks = range(round(Int, Φa)+1, round(Int, Φb)+1; step)
    ax.xminorticks = range(Φa, Φb; step = 1)
    vlines!(ax, [nforced - 0.5, nforced + 0.5]; color = :white, linestyle = :dashdot)
    return ax
end

function plot_LDOS_mJ0(pos, fdata; colormap = cgrad(:thermal)[10:end], colorrange = (5e-4, 5e-2))
    @unpack Φrng, ωrng, LDOS, Δ0, xticks, yticks, xlabel, ylabel, Φa, Φb, ylabelpadding = fdata
    lobe = round.(Int, Φrng)
    ax = Axis(pos; xlabel, ylabel, xticks, yticks, ylabelpadding)
    heatmap!(ax, Φrng, ωrng, (LDOS[0] .+ LDOS[-1].*iseven.(lobe)).*ifelse.(iseven.(lobe), 0.5, 1); colormap, colorrange = (first(colorrange ), last(colorrange )*0.2), lowclip = :black, rasterize = 5)
    xlims!(ax, (Φa, Φb))
    [text!(ax, x, -Δ0; text = ifelse(iseven(x), L"m_J = \pm 1/2", L"m_J = 0"), align = ( ifelse(x == 0, :left, :center), :center), color = :white, fontsize = 15) for x in xticks[2:4]]
    return ax
end

function plot_length(pos, fdata, fdata_length; dlim = 1, colorrange = (10^2, 10^3))
    @unpack Lms = fdata_length 
    @unpack Φrng, ωrng, LDOS, Φa, Φb = fdata 

    LDOS_MZM = sum(values(LDOS)) .> dlim
    ξM = sum(Lms .* LDOS_MZM, dims = 2) 

    ξM[ξM .== 0.0] .= NaN
    ξM = vec(ξM)
    notNaN_ξM = .!isnan.(ξM)
    ξMax = maximum(ξM[findall(notNaN_ξM)])
    ξMin = minimum(ξM[findall(notNaN_ξM)])
    ax = Axis(pos; backgroundcolor = (:white, 0),)
    heatmap!(ax, Φrng, [0], reshape(log10.(ξM), (length(ξM), 1)); colormap = :RdYlGn_9, colorrange, )
    xlims!(ax, (Φa, Φb))
    hideydecorations!(ax)
    hidespines!(ax)
    hidexdecorations!(ax)
    return ax, ξMax, ξMin
end

function rep_length(mod, Φa, Φb, n; path = "Output", dlim = 2e-2)
    fdata = build_data("$path/$mod/semi_uc_$(n).jld2")
    fdata_length = build_data_length("$path/$mod/semi_length_uc_$(n).jld2")
    @unpack Lms = fdata_length 
    @unpack Φrng, ωrng, LDOS = fdata 

    midω = ceil(Int, length(ωrng)/2)
    Ls0 = Lms[:, midω ]
    LDOS0 = LDOS[0][:, midω]
    ξM = Ls0 .* (LDOS0 .> dlim)
    ξM[ξM .== 0.0] .= NaN
    ξM = vec(ξM)

    ind1 = findmin(abs.(Φrng .- Φa))[2]
    ind2 = findmin(abs.(Φrng .- Φb))[2]
    ξM = ξM[ind1:ind2]
    
    return minimum(ξM[findall(.!isnan.(ξM))])*5
end

function plot_length_0(pos, fdata, fdata_length; dlim = 1e-2, colorrange = (log10(150), log10(10900)))
    @unpack Lms = fdata_length 
    @unpack Φrng, ωrng, LDOS, Φa, Φb = fdata 

    midω = ceil(Int, length(ωrng)/2)
    Ls0 = Lms[:, midω ]
    LDOS0 = LDOS[0][:, midω]
    ξM = Ls0 .* (LDOS0 .> dlim)
    ax = Axis(pos; backgroundcolor = (:white, 0),)
    ξM[ξM .== 0.0] .= NaN
    ξM = vec(ξM)
    notNaN_ξM = .!isnan.(ξM)
    ξMax = maximum(ξM[findall(notNaN_ξM)])
    ξMin = minimum(ξM[findall(notNaN_ξM)])
    heatmap!(ax, Φrng, [0], reshape(log10.(ξM), (length(ξM), 1)); colormap = :RdYlGn_9, colorrange  )
    xlims!(ax, (Φa, Φb))
    hideydecorations!(ax)
    hidespines!(ax)
    hidexdecorations!(ax)
    return ax, ξMax, ξMin
end

function pan_label(pos, text; halign = 0.75, valign = 0.95, fontsize = 15, trans = 0.5, width = Auto(), height = Auto(), textpadding = (8,8,8,8))
    Textbox(pos; placeholder = text, tellwidth = false, tellheight = false, halign, valign, textcolor_placeholder = (:black, 0.8), boxcolor = (:white, trans), bordercolor = :transparent, cornerradius = 0, fontsize, width, height, textpadding)
end
