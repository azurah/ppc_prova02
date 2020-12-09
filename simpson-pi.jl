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