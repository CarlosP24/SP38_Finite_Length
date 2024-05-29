using CairoMakie, JLD2, Parameters

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

function plot_prop(mod, L; path = "Output", colormap = cgrad(:thermal)[10:end], colorrange = (5e-4, 5e-2))
    fig = Figure(size = (800, 500), fontsize = 20)


    if L == 0
        gs = "semi"
        subdir = "semi"
    else
        gs = "finite"
        subdir = "L=$(L)"
    end

    # Full LDOS
    indir = "$path/$(mod)/$(subdir).jld2"
    fdata = build_data(indir)
    ax = plot_LDOS(fig[1, 1], fdata; colormap, colorrange)
    hidexdecorations!(ax; ticks = false)

    # mJ = 0
    @unpack Φrng, ωrng, LDOS, Δ0, xticks, yticks, xlabel, ylabel, Φa, Φb, ylabelpadding = fdata
    lobe = round.(Int, Φrng)
    ax = Axis(fig[2, 1]; xlabel, ylabel, xticks, yticks, ylabelpadding)
    heatmap!(ax, Φrng, ωrng, (LDOS[0] .+ LDOS[-1].*iseven.(lobe)).*ifelse.(iseven.(lobe), 0.5, 1); colormap, colorrange = (first(colorrange ), last(colorrange )*0.2), lowclip = :black, rasterize = 5)
    xlims!(ax, (Φa, Φb))
    [text!(ax, x, -Δ0; text = ifelse(iseven(x), L"m_J = \pm 1/2", L"m_J = 0"), align = ( ifelse(x == 0, :left, :center), :center), color = :white, fontsize = 15) for x in xticks[2:end]]
    
    # Under the carpet 1
    nforced = 1 
    indir1 = replace(indir, ".jld2" => "_uc_$(nforced).jld2")
    fdata = build_data(indir1)
    ax = plot_LDOS(fig[1, 2], fdata; colormap, colorrange = (first(colorrange )* 0.5, last(colorrange )*0.1))
    @unpack Φa, Φb, Δ0 = fdata
    ax.xticks = range(round(Int, Φa)+1, round(Int, Φb)+1, step = 2)
    text!(ax, Φa + 1, Δ0*0.1 ; text = L"n = 1", align = (:center, :center), color = :white, fontsize = 15)
    text!(ax, Φa + 1, -Δ0*0.1 ; text = L"m_J = 0", align = (:center, :center), color = :white, fontsize = 15)
    vlines!(ax, [0.5, 1.5]; color = :white, linestyle = :dash)
    hideydecorations!(ax; ticks = false)
    hidexdecorations!(ax; ticks = false)

    # Under the carpet 3
    nforced = 3
    indir3 = replace(indir, ".jld2" => "_uc_$(nforced).jld2")
    fdata = build_data(indir3)
    ax = plot_LDOS(fig[2, 2], fdata; colormap, colorrange = (first(colorrange )* 0.5, last(colorrange )*0.1))
    @unpack Φa, Φb = fdata
    ax.xticks = range(round(Int, Φa)+1, round(Int, Φb)+1, step = 2)
    text!(ax, Φa + 1, Δ0*0.1; text = L"n = 3", align = (:center, :center), color = :white, fontsize = 15)
    text!(ax, Φa + 1, -Δ0*0.1 ; text = L"m_J = 0", align = (:center, :center), color = :white, fontsize = 15)
    vlines!(ax, [2.5, 3.5]; color = :white, linestyle = :dash)

    hideydecorations!(ax; ticks = false)

    cbar = (; colormap = :thermal, label = L"$$ LDOS (arb. units)", limits = (0, 1),  ticklabelsvisible = true, ticks = [0,1], labelpadding = -5,  width = 15, ticksize = 2, ticklabelpad = 5, labelsize = 16)

    Colorbar(fig[1, 3]; cbar...)
    Colorbar(fig[2, 3]; cbar...)

    style = (font = "CMU Serif Bold", fontsize = 20)
    Label(fig[1, 1, TopLeft()], "a",  padding = (-40, 0, -25, 0); style...)
    Label(fig[2, 1, TopLeft()], "b",  padding = (-40, 0, -25, 0); style...)

    Label(fig[1, 2, TopLeft()], "c",  padding = (-20, 0, -25, 0); style...)
    Label(fig[2, 2, TopLeft()], "d",  padding = (-20, 0, -25, 0); style...)

    @unpack data = fdata 
    a0 = data["model"].a0
    R = data["model"].R
    w = data["model"].w
    if L == 0
        Label(fig[1, 1:2, Top()], L"$R=%$(R)$ nm, $w=%$(w)$ nm, semi-infinite"; padding = (0, 0, 10, 0))
    else
        Label(fig[1, 1:2, Top()], L"$R=%$(R)$ nm, $w=%$(w)$ nm, $L=%$(L*a0)$ nm"; padding = (0, 0, 10, 0))
    end
    rowgap!(fig.layout, 1, 10)
    colgap!(fig.layout, 1, 15)
    colgap!(fig.layout, 2, 5)
    fig
end



colorranges = Dict(
    "HCA_70" => (5e-4, 5e-2),
    "HCA_50" => (5e-4, 2e-2),
    "HCA_30" => (1e-4, 1e-2),
    "TCM_20" => (5e-4, 2e-2),
    "TCM_15" => (1e-4, 1e-2),
    "SCM_70" => (5e-4, 2e-1),
)

mod = "SCM_70"
L = 0 
fig = plot_prop(mod, L; colorrange = colorranges[mod])
fig

## Loop
for mod in ["HCA_70", "HCA_50","TCM_20", "TCM_15"]
    for L in range(0, 200, step = 50)
        fig = plot_prop(mod, L; colorrange = colorranges[mod])
        save("Figures/Proposals/$(mod)_$(L).pdf", fig)
    end
end 

for mod in ["SCM_70"]
    for L in range(0, 2000, step = 500)
        fig = plot_prop(mod, L; colorrange = colorranges[mod])
        save("Figures/Proposals/$(mod)_$(L).pdf", fig)
    end
end