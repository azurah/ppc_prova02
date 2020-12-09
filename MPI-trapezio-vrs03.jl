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