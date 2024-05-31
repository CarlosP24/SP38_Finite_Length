# Header, load and parallelize 
using Pkg
Pkg.activate(".")
Pkg.instantiate()

using Distributed, JLD2

nodes = open("machinefile") do f
    read(f, String)
    end
nodes = split(nodes, "\n")
pop!(nodes)
nodes = string.(nodes)
my_procs = map(x -> (x, :auto), nodes)

addprocs(my_procs; exeflags="--project", enable_threaded_blas = false)

# Main 

using JLD2
@everywhere begin
    using FullShell, Parameters, ProgressMeter, Quantica
    include("functions.jl")
end

# Global config 
Φlength = 400
ωlength = 401
Φrng = subdiv(0, 3.5, Φlength)
ωrng = subdiv(-.26, .26, ωlength) .+ 1e-4im
Zs = -5:5 

# Include code
include("models.jl")
include("calcs/calc_LDOS.jl")
include("calcs/calc_length.jl")

# Run

mod = ARGS[1]
L = parse(Int64, ARGS[2])

#calc_LDOS(mod, L; Φrng, ωrng, Zs)

Φrng = subdiv(-8, 5.5, Φlength*2)
# calc_LDOS(mod, L; Φrng, ωrng, Zs = 0, nforced = 1)
# calc_LDOS(mod, L; Φrng, ωrng, Zs = 0, nforced = 3)


if L == 0
    calc_Length(mod, L; Φrng, ωrng, nforced = 1)
end

# Clean up 
rmprocs(workers()...)

