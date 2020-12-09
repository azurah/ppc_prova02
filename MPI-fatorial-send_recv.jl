#=
Versão fatorial com comunicação
Autor: Edvan S. Sousa
Ano: dezembro 2020
Problema original: fatorial com comunicação
Versão Julia:MPI-fatorial-send_recv
=#
import MPI

MPI.Init()
comm = MPI.COMM_WORLD
comm_sz = MPI.Comm_size(comm)
my_rank = MPI.Comm_rank(comm)

#Função fatorial modificada
function fat(n)
    if n > 0
        return n*fat(n-4)
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
        parcial = fat(n)
        for q in 1:comm_sz
            MPI.Irecv!(recv_mesg, q, tag, comm)
            parcial = parcial*recv_mesg[1]
        end
        print("O resultado do fat de $n é = $parcial")
    end
    if my_rank == 1
        result = fat(n-1)
        # preenche send_msg com result
        fill!(send_mesg, Float64(result))
        MPI.Isend(send_mesg, root, tag, comm)
    end
    if my_rank == 2
        result = fat(n-2)
        # preenche send_msg com result
        fill!(send_mesg, Float64(result))
        MPI.Isend(send_mesg, root, tag, comm)
    end
    if my_rank == 3
        result = fat(n-3)
        # preenche send_msg com result
        fill!(send_mesg, Float64(result))
        MPI.Isend(send_mesg, root, tag, comm)
    end
end

MPI.Barrier(comm)
MPI.Finalize()

main()