
Avaliação 02
=============

Edvan S. Sousa / Jonathan Matheus.

#### Questões codificadas:

1. fatorial 
2. fatorial MPI parametrizado
3. Fatorial MPI simples
4. Fatorial MPI send_recv
5. Hello MPI com comunicação
6. Hello MPI simples
7. Simpson MPI pi
8. Simpson MPI reduction
9. Trapezio MPI versão 01
10. Trapezio MPI versão 02
11. Trapezio MPI versão 03

Implementações
==============



~~~fatorial.jl
# Mpi Fatorial

function fat(n)
    if n == 0
       return 1
    else
        return n*fat(n-1)
    end
end

function main()
    n = 10
    f = fat(n)
    print("Para o vlr $n temos o fat = $f")
end

main()
~~~



~~~MPI_fatorial_parametrizado.jl

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
~~~



~~~fat-send_recv.jl

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
~~~



~~~fat-simples.jl

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
~~~



~~~hello-comm.jl

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
~~~


~~~hello-MPI-simples.jl
# Hello MPI
# MPI-Hello
import MPI

MPI.Init()
comm = MPI.COMM_WORLD

# Function main()
function main()

print("Hello world, I am rank $(MPI.Comm_rank(comm)) of $(MPI.Comm_size(comm))\n")
    
MPI.Barrier(comm)
MPI.Finalize() # Opcional. Invocado automaticamente qdo Julia encerra. 
end

main()
~~~

~~~simpson-reduction.jl

import MPI

function f(x)
	sqrt(1 - x * x)
end

function Simps(a, b, n)
	sum1 = 0
	sum2 = 0
	h = (b - a) / n
	y0 = f(a + 0 * h)
	yn = f(a + n * h)
	for i in 1:n-1
		if (i % 2) == 0
			sum1 += f(a + i * h)
		else
			sum2 += f(a + i * h)
		end
	end
	s = (h / 3) * (y0 + yn + 2 * sum1 + 4 * sum2)
end

function main()
	MPI.Init()
	comm = MPI.COMM_WORLD
	size = MPI.Comm_size(comm)
	rank = MPI.Comm_rank(comm)

	if rank == 0
		print("Entre o numero de intervalos desejados: \n")
		n = parse(Int64, readline())
	else
		n = 0
	end

	n = MPI.bcast(n, 0, comm)

	local_n = n / size
	h = 1 / size

	local_a = 0 + rank * h
	local_b = local_a + h

	local_Pi = Simps(local_a, local_b, local_n)

	MPI.Barrier(comm)

	final_Pi = MPI.Reduce(local_Pi, +, 0, comm)

	if rank == 0
		final_Pi *= 4
		print("Com n = $n intervalos, nossa estimativa\n")
		print("para o valor de Pi eh $final_Pi\n")
		print("com precisao de $(final_Pi - pi)")
	end

	MPI.Finalize()
end

main()

~~~


~~~trapezio-vrs01.jl

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

~~~

~~~trapezio-vrs02.jl

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

~~~

~~~trapezio-vrs03.jl

import MPI

function f(x::Float64)
	return x*x
end

function Trap(left_endpt, right_endpt, trap_count, base_len)

	local estimate, x, i
	estimate = (f(left_endpt) + f(right_endpt))/2
	for i in 1:trap_count-1
		x = left_endpt + i*base_len
		estimate += f(x)
	end
	estimate *= base_len
	return estimate
end	

function main()

	MPI.Init()
	comm = MPI.COMM_WORLD
	size = MPI.Comm_size(comm)
	rank = MPI.Comm_rank(comm)

	if rank == 0
		print("Entre com os limites a, b da integral definida: \n")
		a = parse(Float64, readline())
		b = parse(Float64, readline())
		print("Entre o numero de trapezios desejados: \n")
		n = parse(Int64, readline())
	else
		a = 0.0
		b = 0.0
		n = 0
	end

	a = MPI.bcast(a, 0, comm)
	b = MPI.bcast(b, 0, comm)
	n = MPI.bcast(n, 0, comm)

	h = (b - a) / n
	local_n = n / size

	local_a = a + rank * local_n * h
	local_b = local_a + local_n * h
	local_int = Trap(local_a, local_b, local_n, h)

	total_int = MPI.Reduce(local_int, +, 0, comm)

	if rank == 0
		print("Com n = $n trapezoides, nossa estimativa\n")
		print("da integral de $a e $b = $total_int")
	end

end

main()
~~~

~~~simpson-MPI.jl

#=
Versão Trapézio com comunicação
Autor: Edvan S. Sousa
Ano: dezembro 2020
Problema original: PI Simpson
Versão Julia: simpson-pi
=#
function f(x)
    return sqrt(1-x*x)
end

function simps(a, b, n)
    h = 0.0
    sum1 = 0.0
    sum2 = 0.0
    sum = 0.0
    y0 = 0.0
    yn = 0.0
    i = 0
    h = (b-a)/n
    y0 = f(a + 0*h)
    yn = f(a + n*h)
    
    for i in 1:n-1
        if i%2 == 0
            sum1 += f(a + i*h)
        else
            sum2 = sum2 + f(a + i*h)
        end
    end
    sum = (h/3)*(y0 + yn + 2*sum1 +4*sum2)
    return sum
end

function main()
    PI = 4*simps(0, 1, 10)
    println("Valor: $PI")
end

main()
~~~
