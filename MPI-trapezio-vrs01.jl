import MPI

function f(x)
    #return x*x
    x*x
end

function Trap(left_endpt, right_endpt, trap_count, base_len)
   
    estimate = (f(left_endpt) + f(right_endpt))/2.0
    for i in 1:trap_count - 1    
        x = left_endpt + i*base_len
        estimate += f(x)
    end
    estimate = estimate * base_len
    #return implicito
end

function main()
    MPI.Init()
    
    comm = MPI.COMM_WORLD
    rank = MPI.Comm_rank(comm)
    size = MPI.Comm_size(comm)    

    n = 1024
    a = 0
    b = 3

    h = (b - a) / n
    local_n = n / size

    local_a = a + rank * local_n * h
    local_b = local_a + local_n * h
    local_int = Trap(local_a, local_b, local_n, h)

    if (rank != 0)
        send_mesg = Array{Float64}(fill(local_int, 1))
        MPI.Send(send_mesg, 0, 0, comm)

    else  
        total_int = local_int
        for source in 1 : size - 1
            recv_mesg = Array{Float64}(undef, 1)
            MPI.Recv(recv_mesg, source, 0, comm)
            total_int += local_int
        end
    end

    if (rank == 0)
        println("Com n = $n trapezoides, nossa estimativa")
        print("da integral de $a a $b = $total_int")
    end    
    MPI.Finalize()

end
main()