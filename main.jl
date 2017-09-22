using JuMP
using GLPKMathProgInterface

type Problem
         Variables
         LeftMembers_Constraints
         RightMembers_Constraints
end

#MODEL CONSTRUCTION
#--------------------
#m           = Model(solver=GLPKSolverLP())
m           = Model(solver=GLPKSolverMIP())
#READING DATA FROM FILE
#     GETTING NB OF VARIABLES AND CONSTRAINTS
#     AND VALUES ASSOCIATED TO THEM
files       = open("/home/jack/ORO/MetaHeuristics/Projet/DM1/Data/pb_100rnd0100.dat");
lines       = readlines(files)
counter     = 1
counter2    = 1
VarAndCons  = split(lines[1])
NBcons      = parse(VarAndCons[1])
NBvar       = parse(VarAndCons[2])

values      = split(lines[2])
Coef        = Vector(NBvar)

for val in eachindex(values)
   Coef[val]=parse(values[val])
end
@variable(  m,  0 <= x[1:NBvar] <= 1,Int)
@objective( m , Max, sum( Coef[j] * x[j] for j=1:NBvar ) )

#@variable(  m, x[1:NBvar], Bin )
#@objective( m, Max, dot( Coef, x ) )
LeftMembers_Constraints    = spzeros(NBcons,NBvar)
RightMembers_Constraints   = Vector(NBcons)

deleteat!(lines,1)
deleteat!(lines,1)
for line in lines
   values = split(line)
   if counter%2 == 1
      #RightMembers_Constraints[counter2]=parse(values[1])
      RightMembers_Constraints[counter2]=1
   else
      for val in values
         LeftMembers_Constraints[counter2,parse(val)]=1
         #parcours chaque valeurs (chaque valeur est separer par un espace)
         #ecrire dfct get value qui renvoie un tableau
         #lire dabord la pemiere ligne
         #puis lire le reste du fichier grace au infos obtenu dans la premiere ligne
      end
      counter2+=1
   end
   counter+=1
end
@constraint( m , cte[i=1:NBcons], sum(LeftMembers_Constraints[i,j] * x[j] for j=1:NBvar) <= RightMembers_Constraints[i] )
#@constraint(m, dot(LeftMembers_Constraints, x) <= RightMembers_Constraints)
println("The optimization problem to be solved is:")
print(m) # Shows the model constructed in a human-readable form

#SOLVE IT AND DISPLAY THE RESULTS
#--------------------------------
status = solve(m) # solves the model

println("Objective value: ", getobjectivevalue(m)) # getObjectiveValue(model_name) gives the optimum objective value
for i in 1:NBvar
   println("x",i," = ", getvalue(x[i]))
end
