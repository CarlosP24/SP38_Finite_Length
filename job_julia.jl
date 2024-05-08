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

include("models.jl")
include("calcs/calc_LDOS.jl")

mod = ARGS[1]
L = parse(Int64, ARGS[2])

calc_LDOS(mod, L)

# Clean up 
rmprocs(workers()...)

