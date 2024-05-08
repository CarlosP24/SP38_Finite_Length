function calc_LDOS(mod, L)

    if L == 0
        gs = "semi"
        subdir = "semi"
    else
        gs = "finite"
        subdir = "L=$(L)"
    end

    # Setup Output
    outdir = "Output/$(mod)/$(subdir).jld2"
    mkpath(dirname(outdir))

    # Basic config
    Φrng = subdiv(0, 2.5, 200)
    ωrng = subdiv(-.26, .26, 201) .+ 1e-4im 
    Zs = -5:5

    # Load models
    model = models[mod]
    model = (; model..., L = L)

    # Build nanowire
    hSM, hSC, params = build_cyl(; model...,)

    # Get Greens
    g = greens_dict[gs](hSC, params)

    # Run n save LDOS
    LDOS = calc_ldos(ldos(g[cells = (-1,)]), Φrng, ωrng, Zs)

    save(outdir, 
        Dict(
            "model" => model,
            "Φrng" => Φrng,
            "ωrng" => ωrng,
            "LDOS" => LDOS
        )
    )
end

function calc_LDOS_uc(mod, L; n = 1)
    if L == 0
        gs = "semi"
        subdir = "semi"
    else
        gs = "finite"
        subdir = "L=$(L)"
    end

    # Setup Output
    outdir = "Output/$(mod)/$(subdir)_uc_$(n).jld2"
    mkpath(dirname(outdir))

    # Basic config
    Φlims = ifelse(mod == Any["SCM", "SCM_small"], (-15, 10), (-10, 1))
    Φrng = ifelse(iseven(n), subdiv(n - 2, n + 2, 200), subdiv(n + first(Φlims), n + last(Φlims), 200))
    ωrng = subdiv(-.1, .1, 201) .+ 1e-4im 
    Zs = ifelse(iseven(n), -1:0, 0)

    # Load models
    model = models[mod]
    model = (; model..., L = L)

    # Build nanowire
    hSM, hSC, params = build_cyl(; model..., ξd = 0, nforced = n)

    # Get Greens
    g = greens_dict[gs](hSC, params)

    # Run n save LDOS
    LDOS = calc_ldos(ldos(g[cells = (-1,)]), Φrng, ωrng, Zs)

    save(outdir, 
        Dict(
            "model" => model,
            "Φrng" => Φrng,
            "ωrng" => ωrng,
            "LDOS" => LDOS
        )
    )
end