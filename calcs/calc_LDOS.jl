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