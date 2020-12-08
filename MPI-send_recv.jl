#https://ddd.uab.cat/pub/artpub/2016//174327/comeco_a2016v48p535iENG_postprint.pdf
import MPI
import Statistics

function main()
    
    MPI.Init()
    comm = MPI.COMM_WORLD
    size = MPI.Comm_size(comm)
    rank = MPI.Comm_rank(comm)
    
    recv_mesg = zeros(100, 1)
    
    if rank == 0
        send_mesg = rand(100, 1)
        for i = 1:size-1
            MPI.Send(send_mesg, i, 0, comm)
        end
    else
        MPI.Recv!(recv_mesg, 0, 0, comm)
    end
    
    m = Statistics.mean(+, recv_mesg)
    sleep(rank*2)
    println("Results: rank: ", rank, " -> média: ", m)
    
    MPI.Barrier(comm)
    MPI.Finalize()
end

main()