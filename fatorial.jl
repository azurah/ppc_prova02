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