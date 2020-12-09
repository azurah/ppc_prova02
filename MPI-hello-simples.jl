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