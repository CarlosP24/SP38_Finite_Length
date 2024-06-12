base_model = (;
    R = 70,
    w = 0,
    d = 0,
    Δ0 = 0.23,
    ξd = 70,
    a0 = 5,
    preα = 0,
    g = 0,
    α = 0,
    μ = 0,
    τΓ = 1,
    Vexponent = 2,
    Vmin = 0,
    Vmax = 0,
    ishollow = true,
)
models = Dict(
    "HCA_70" => (;
        base_model...,
        μ = 0.75,
        α = 85,
    ),
    "HCA_30" => (;
        base_model...,
        R = 30,
        μ = 0.75,  
        α = 30,
    ),
    "HCA_50" => (;
        base_model...,
        R = 50,
        μ = 0.75,  
        α = 50,
    ),
    "TCM_20" => (;
        base_model...,
        w = 20,
        d = 10,
        τΓ = 10,
        μ = 18.1,
        α = 50,
        g = 10,
        ishollow = false,
    ),
    "TCM_15" => (;
        base_model...,
        R = 50,
        w = 15,
        d = 10,
        τΓ = 9,
        μ = 25.7,
        α = 25,
        g = 10,
        ishollow = false,
    ),
    "TCM_10" => (;
        base_model...,
        R = 30,
        w = 10,
        d = 10,
        τΓ = 8,
        μ = 39.1,
        α = 10,
        g = 10,
        ishollow = false,
    ),
    "SCM_70" => (;
        base_model...,
        w = 70,
        d = 10,
        Vmin = -30,
        g = 10,
        τΓ = 40,
        μ = 2,
        preα = 46.66,   
        ishollow = false,
    ),
    "SCM_30" => (;
        base_model...,
        R = 30,
        w = 30,
        d = 10,
        Vmin = -30,
        g = 10,
        τΓ = 40,
        μ = 2,
        preα = 46.66,
        ishollow = false,
    ),
    "Pablos_test" => (;
        base_model...,
        Δ0 = 0.1,
        α = 100,
        R = 40,
        d = 0,
        w = 0,
        μ =1.3 
    ),
    "Pablos_test2" => (;
    base_model...,
    Δ0 = 0.1,
    α = 40,
    R = 40,
    d = 0,
    w = 0,
    μ = 0.5
    ),
    "Pablos_test3" => (;
    base_model...,
    Δ0 = 0.1,
    α = 40,
    R = 17,
    d = 8,
    w = 0,
    μ = 2.65
    ),
)
ranges = Dict(
    "TCM_20" => (;
        Φa = -8,
        Φb = 5.5,
        Φaf = -8,
        Φbf = 5.5
    ),
    "TCM_10" => (;
        Φa = -2,
        Φb = 4.5,
        Φaf = -2,
        Φbf = 4.5
    ),
    "SCM_70" => (;
        Φa = -30,
        Φb = 34,
        Φaf = -9,
        Φbf = 11
    ),
    "SCM_30" => (;
        Φa = -9,
        Φb = 11,
        Φaf = -9,
        Φbf = 11
    ),
)
