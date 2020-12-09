#=
Versão fatorial com comunicação parametrizado
Autor: Edvan S. Sousa
Ano: dezembro 2020
Problema original: fatorial com comunicação parametrizado
Versão Julia:MPI-fatorial-param
=#
import MPI

MPI.Init()
comm = MPI.COMM_WORLD
comm_sz = MPI.Comm_size(comm)
my_rank = MPI.Comm_rank(comm)

#Função fatorial
function fat(n, sz)
    if n > 0
        return n*fat(n-sz, sz)
    else
        return 1
    end
end

function main()
    tag = 0
    root = 0
    result = 1
    parcial = 1
    n = 10
    send_mesg = Array{Float64}(undef, 1)
    recv_mesg = Array{Float64}(undef, 1)
    
     if my_rank == root
        parcial = fat(n-my_rank, comm_sz)
        for q in 1:comm_sz
            MPI.Irecv!(recv_mesg, q, tag, comm)
            parcial = parcial*recv_mesg[1]
        end
        print("O resultado do fatorial de $n é = $parcial")
    else
        result = fat(n-my_rank, comm_sz)
        fill!(send_mesg, Float64(result))
        MPI.Irecv!(send_mesg, root, tag, comm)
    end
    
end

MPI.Barrier(comm)
MPI.Finalize()

main()