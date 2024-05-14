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

    # Default config
    !@isdefined(Φrng) && (Φrng = subdiv(0, 2.5, 200))
    !@isdefined(ωrng) && (ωrng = subdiv(-.26, .26, 201) .+ 1e-4im)
    !@isdefined(Zs) && (Zs = -5:5)

    # Load models
    model = models[mod]
    model = (; model..., L = L)

    # Build nanowire
    hSM, hSC, params = build_cyl(; model...,)

    # Get Greens
    g = greens_dict[gs](hSC, params)

    # Run n save LDOS
    LDOS = calc_ldos(ldos(g[cells = (-1,)]), Φrng, ωrng, Zs)
    ΦLP_lims = LP_lobe(1, model.ξd, model.R, model.d)

    save(outdir, 
        Dict(
            "model" => model,
            "Φrng" => Φrng,
            "ωrng" => ωrng,
            "LDOS" => LDOS,
            "Φlims" => ΦLP_lims
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

    # Default config
    if !@isdefined(Φrng) 
        Φlims = ifelse(mod == Any["SCM", "SCM_small"], (-15, 10), (-10, 1))
        !@isdefined(Φlength) && (Φlength = 200)
        Φrng = ifelse(iseven(n), subdiv(n - 2, n + 2, Φlength), subdiv(n + first(Φlims), n + last(Φlims), Φlength))
    end

    !@isdefined(ωrng) && (ωrng = subdiv(-.26, .26, 201) .+ 1e-4im)
    !@isdefined(Zs) && (Zs = 0)

    # Load models
    model = models[mod]
    model = (; model..., L = L)

    # Build nanowire
    hSM, hSC, params = build_cyl(; model..., nforced = n)

    # Get Greens
    g = greens_dict[gs](hSC, params)

    # Run n save LDOS
    LDOS = calc_ldos(ldos(g[cells = (-1,)]), Φrng, ωrng, Zs)

    save(outdir, 
        Dict(
            "model" => model,
            "Φrng" => Φrng,
            "ωrng" => ωrng,
            "LDOS" => LDOS,
        )
    )
end