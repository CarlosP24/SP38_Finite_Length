function calc_Length(mod, L)
    if L == 0
        gs = "semi"
        subdir = "semi"
    else
        gs = "finite"
        subdir = "L=$(L)"
    end

    # Setup Output
    outdir = "Output/$(mod)/$(subdir)_length.jld2"
    mkpath(dirname(outdir)) 

    # Default config 
    !@isdefined(Φrng) && (Φrng = subdiv(0.501, 1.499, 200))
    !@isdefined(ωrng) && (ωrng = subdiv(-.26, .26, 201) .+ 1e-4im)
    
    # Load models
    model = models[mod]
    model = (; model..., L = L)

    # Build nanowire
    hSM, hSC, params = build_cyl(; model...,)

    # Get Greens
    g = greens_dict[gs](hSC, params)

    # Run n save 
    Lms = calc_length(g, Φrng, ωrng; ω = 0.0 + 1e-4im, Z = 0)

    save(outdir,
        Dict(
            "model" => model,
            "Φrng" => Φrng,
            "Lms" => Lms
        )
    )
end