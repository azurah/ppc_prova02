#fatorial com MPI simples
import MPI
#import BenchmarkTools

MPI.Init()
const comm = MPI.COMM_WORLD
const size = MPI.Comm_size(comm)
const rank = MPI.Comm_rank(comm)

function fat(n)
    if n == 0
        return 1
    else
        return n*fat(n-1)
    end
end

function main()
    #n = 10
    n = readline()
    n = parse(Int64, n) 
    f = fat(n)
    print("processadores: $size, rank: $rank, vlr atribuído: $n, fat($n) = $f")
end

MPI.Barrier(comm)
MPI.Finalize()

#@time main()
