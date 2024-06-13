function calc_LDOS(mod, L; Φrng = subdiv(0.501, 1.499, 200), ωrng = subdiv(-.26, .26, 201) .+ 1e-4im, Zs = -5:5, nforced = nothing, path = "Output")

    if L == 0
        gs = "semi"
        subdir = "semi"
    else
        gs = "finite"
        subdir = "L=$(L)"
    end

    # Setup Output
    outdir = "$(path)/$(mod)/$(subdir).jld2"
    mkpath(dirname(outdir))

    # Load models
    model = models[mod]
    model = (; model..., L = L)

    if nforced !== nothing
        model = (; model..., ξd = 0)
        outdir = replace(outdir, ".jld2" => "_uc_$(nforced).jld2")
    end

    # Build nanowire
    hSM, hSC, params = build_cyl(; model..., nforced)

    # Get Greens
    g = greens_dict[gs](hSC, params)

    # Run n save LDOS
    LDOS = calc_ldos(ldos(g[cells = (-1,)]), Φrng, ωrng, Zs)
    #ΦLP_lims1 = LP_lobe(1, model.ξd, model.R, model.d)
    #ΦLP_lims3 = LP_lobe(3, model.ξd, model.R, model.d)

    save(outdir, 
        Dict(
            "model" => model,   
            "Φrng" => Φrng,
            "ωrng" => ωrng,
            "LDOS" => LDOS,  
            )
    )
end

function calc_LDOS_rad(mod; L = 0, Φrng = subdiv(0.501, 1.499, 200), ω = 0.0 + 1e-4im, Z = 0, nforced = nothing, path = "Output")

    if L == 0
        gs = "semi"
        subdir = "semi"
    else
        gs = "finite"
        subdir = "L=$(L)"
    end

    # Setup Output
    outdir = "$(path)/$(mod)/$(subdir)_radial.jld2"
    mkpath(dirname(outdir))

    # Load models
    model = models[mod]
    model = (; model..., L = L)

    if nforced !== nothing
        model = (; model..., ξd = 0)
        outdir = replace(outdir, ".jld2" => "_uc_$(nforced).jld2")
    end

    # Build nanowire
    hSM, hSC, params = build_cyl(; model..., nforced)

    # Get Greens
    g = greens_dict[gs](hSC, params)

    # Run n save LDOS
    LDOS = calc_ldos_r(ldos(g[cells = (-1,)]), Φrng; ω, Z)

    save(outdir, 
        Dict(
            "model" => model,
            "Φrng" => Φrng,
            "ω" => ω,
            "Z" => Z,
            "LDOS" => LDOS,
        )
    )
end