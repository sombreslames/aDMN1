#Ferrari Leon
#M1 ORO
#Version de test
#Julia JuMP
#DM1 - Metaheuristiques
using JuMP, GLPKMathProgInterface, PyPlot
type Problem
   NBvariables::Int
   NBconstraints::Int
   Variables
   LeftMembers_Constraints
   RightMembers_Constraints
end

function ReadFile(FileName)
   workingfile = open(FileName);
   lines       = readlines(workingfile)
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
   close(workingfile)
   return Problem(NBvar,NBcons,Coef,LeftMembers_Constraints,RightMembers_Constraints)
end

#GETTING DATA FRON FILE
FileList = readdir("./Data")
dir = pwd()
x_cpuTime = Vector(length(FileList))
y_problemSize = Vector(length(FileList))
z_problemConstraints = Vector(length(FileList))
for i in eachindex(FileList)
   #MODEL CONSTRUCTION
   #--------------------
   m           = Model(solver=GLPKSolverMIP())
   #READING DATA FROM FILE
   #     GETTING NB OF VARIABLES AND CONSTRAINTS
   #     AND VALUES ASSOCIATED TO THEM
   FilePath    =
   BPP = ReadFile(string("./Data/",FileList[i]))
   if BPP.NBvariables < 1000 && BPP.NBconstraints < 1000
      tic()
      @variable(  m,  0 <= x[1:BPP.NBvariables] <= 1,Int)
      @objective( m , Max, sum( BPP.Variables[j] * x[j] for j=1:BPP.NBvariables ) )
      @constraint( m , cte[i=1:BPP.NBconstraints], sum(BPP.LeftMembers_Constraints[i,j] * x[j] for j=1:BPP.NBvariables) <= BPP.RightMembers_Constraints[i] )
      #@constraint(m, dot(LeftMembers_Constraints, x) <= RightMembers_Constraints)
      #println("The optimization problem to be solved is:")
      #print(m) # Shows the model constructed in a human-readable form

      #SOLVE IT AND DISPLAY THE RESULTS
      #--------------------------------
      status = solve(m) # solves the model
      x_cpuTime[i]=toc()
      y_problemSize[i]=BPP.NBvariables
      z_problemConstraints[i]=BPP.NBconstraints
      println("Objective value: ", getobjectivevalue(m)) # getObjectiveValue(model_name) gives the optimum objective value
   end
end
