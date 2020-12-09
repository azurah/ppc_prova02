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