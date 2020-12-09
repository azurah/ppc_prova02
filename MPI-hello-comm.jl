#=
Versão Hello com comunicação
Autor: Jonathan
Ano: dezembro 2020
Problema original: Hello
Versão Julia: MPI-hello-comm.jl
=#
import MPI

MPI.Init()
comm = MPI.COMM_WORLD
size = MPI.Comm_size(comm)
rank = MPI.Comm_rank(comm)

if (rank != 0)
    send_mesg = Vector{Char}("Eu sou $rank de $size")
    MPI.Send(send_mesg, 0, 0, comm)
else
    println("Eu sou $rank de $size ")
    for i in 1:size-1
        recv_mesg = Vector{Char}(undef, 40)
        MPI.Recv!(recv_mesg, i, 0, comm)
        println(String(recv_mesg))
    end
end

sleep(rank*4)
MPI.Barrier(comm)
MPI.Finalize()