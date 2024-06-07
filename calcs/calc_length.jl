function calc_Length(mod, L; Φrng = subdiv(0.501, 1.499, 200), ωrng = subdiv(-.26, .26, 201) .+ 1e-4im, nforced = nothing, Z = 0, path = "Output")
    if L == 0
        gs = "semi"
        subdir = "semi"
    else
        gs = "finite"
        subdir = "L=$(L)"
    end

    # Setup Output
    outdir = "$(path)/$(mod)/$(subdir)_length.jld2"
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

    # Run n save 
    Lms = calc_length(g, Φrng, ωrng; ω = 0.0 + 1e-4im, Z)

    save(outdir,
        Dict(
            "model" => model,
            "Φrng" => Φrng,
            "Lms" => Lms
        )
    )
end