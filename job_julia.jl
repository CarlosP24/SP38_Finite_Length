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
Φlength = 200
ωlength = 201
Φrng = subdiv(0, 2.5, Φlength)
ωrng = subdiv(-.26, .26, ωlength) .+ 1e-4im
Zs = -5:5 

# Include code
include("models.jl")
include("calcs/calc_LDOS.jl")
include("calcs/calc_length.jl")

# Run

mod = ARGS[1]
L = parse(Int64, ARGS[2])

calc_LDOS(mod, L; Φrng, ωrng, Zs)

Φrng = subdiv(-10, 2.5, Φlength*10)
calc_LDOS(mod, L; Φrng, ωrng, Zs, nforced = 1)

if L == 0
    Φrng = subdiv(0.501, 1.499, Φlength)
    calc_Length(mod, L)
end

# Clean up 
rmprocs(workers()...)

