#=
Versão Trapézio com comunicação
Autor: Edvan S. Sousa
Ano: dezembro 2020
Problema original: trapézio vrs02
Versão Julia: MPI-trapezio-vrs02

Versão 01: limites da integral [a, b] e número de trapézios
n são fixados dentro do código.
=#

import MPI

comm = MPI.COMM_WORLD
comm_sz = MPI.Comm_size(comm)
my_rank = MPI.Comm_rank(comm)

#Função a ser calculada
function f(x)
    return x*x;
end

#Regra trapezoidal composta para integração numérica
function trap(left_endpt, right_endpt, trap_count, base_len)
    estimate = 0.0
    x = 0.0
    estimate = (f(left_endpt) + f(right_endpt))/2.0
    for i in 1:trap_count-1
        x = left_endpt + i*base_len
        estimate += f(x)
    end
    estimate = estimate*base_len
    return estimate
end

function main()
    n = 1024
    local_n = 0
    a = 0.0
    b = 3.0
    h = 0.0
    local_a = 0.0
    local_b = 0.0
    local_int = 0.0
    total_int = 0.0
    send_mesg = Array{Float64}(undef, 1)
    recv_mesg = Array{Float64}(undef, 1)
    tag = 0
    root = 0
    
    h = (b-a)/n
    local_n = n/comm_sz
    # Intervalo de integração de cada processo = local_n*h
    # logo, o intervalo de cada processo começa em:
    local_a = a + my_rank*local_n*h
    local_b = local_a + local_n*h
    local_int = trap(local_a, local_b, local_n, h)
    #Processo 0 (zero) calcula sua integral local e soma as enviadas pelos demais processos.
    if my_rank != root
        # preenche send_msg com result
        fill!(send_mesg, Float64(local_int))
        MPI.Isend(send_mesg, 1, tag, comm)
    else
        total_int = local_int
        for source in 1:comm_sz
            MPI.Irecv!(recv_mesg, source, tag, comm)
            total_int += recv_mesg[1]
        end
    end
    if my_rank == 0
        print("Com n = $n, nossa estimativa\n")
        print("da integral de $a até $b é $total_int ")
    end
    
    
end

MPI.Barrier(comm)
MPI.Finalize()

main()