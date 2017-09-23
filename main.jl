#Ferrari Leon
#M1 ORO
#Version de test
#Julia JuMP
#DM1 - Metaheuristiques
module DM1_metaheuristics
using JuMP, GLPKMathProgInterface, PyPlot, myHeuristics.jl
type Problem
   NBvariables::Int
   NBconstraints::Int
   Variables::Vector(NBvariables)
   LeftMembers_Constraints::spzeros(NBconstraints,NBvariables)
   RightMembers_Constraints::Vector(NBconstraints)
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
   #m           = Model(solver=GLPKSolverLP())
   m           = Model(solver=GLPKSolverMIP())
   #READING DATA FROM FILE
   #     GETTING NB OF VARIABLES AND CONSTRAINTS
   #     AND VALUES ASSOCIATED TO THEM
   filename    = string(dir,"/Data/",FileList[i])
   workingfile = open(filename);
   lines       = readlines(workingfile)
   counter     = 1
   counter2    = 1
   VarAndCons  = split(lines[1])
   NBcons      = parse(VarAndCons[1])
   NBvar       = parse(VarAndCons[2])
   if NBcons < 1000 && NBvar < 1000
      values      = split(lines[2])
      Coef        = Vector(NBvar)
      tic()
      for val in eachindex(values)
         Coef[val]=parse(values[val])
      end
      @variable(  m,  0 <= x[1:NBvar] <= 1,Int)
      @objective( m , Max, sum( Coef[j] * x[j] for j=1:NBvar ) )

      #@variable(  m, x[1:NBvar], Bin )
      #@objective( m, Max, dot( Coef, x ) )
      LeftMembers_Constraints    = spzeros(NBcons,NBvar)
      RightMembers_Constraints   = Vector(NBcons)
NBvar
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
      #println("The optimization problem to be solved is:")
      #print(m) # Shows the model constructed in a human-readable form

      #SOLVE IT AND DISPLAY THE RESULTS
      #--------------------------------
      status = solve(m) # solves the model
      x_cpuTime[i]=toc()
      y_problemSize[i]=NBvar
      z_problemConstraints[i]=NBcons
      println("Objective value: ", getobjectivevalue(m)) # getObjectiveValue(model_name) gives the optimum objective value
   end
   close(workingfile)
end
function ReadFile(FileName::string)
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
