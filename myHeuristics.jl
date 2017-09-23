#Algorithme de descente glouton
#Principe de cet algorithme :
#Creation d'un heuristique de construction permettant de trouver solution admissible x0
#cette heuristique de depart sera develloper ici
#Mise en place d'une heuristique de recherche locale de type plus profonde descente
#Celle ci sera fondee sur deux voisins
module DM1_metaheuristics
export CurrentSolution,FindingAdmissingBaseSolution1,DeepLocalSearch,IsConsistent,
#Order variable by decreasing cost
#Align the constraints with the variable order
#Compute the ratio between the cost and the total number of occurence of the variable in all the constraints
type CurrentSolution
   NBconstraints::Int
   NBvariables::Int
   CurrentVarIndex::Int
   CurrentObjectiveValue::Int
   LeftMemberValues::Vector(NBconstraints)
   Coefficients::Vector(NBvariables)
   Constraints::Array(NBconstraints,NBvariables)
end
function FindingAdmissingBaseSolution1(CS::CurrentSolution)
   Ratio = Array(2,CS.NBvariables)
   for i in 1:1:CS.NBvariables
      nb =  0
      for j in 1:1:CS.NBconstraints
            if CS.Constraints[i][j] == 1
               nb += 1
            end
      end
      Ratio[1][i]= i
      Ratio[2][i]= CS.Coefficients[i]/nb
   end
   sortcols(Ratio)
   println(Ratio)
end
#Fonction recursive permettant l'eploration des solutions voisines admissibles
function DeepLocalSearch(CS::CurrentSolution,TryingPos::Int)


end
#LastLeftMemberValue sera un vecteur contenant la derniere valeur calculee pour la somme des membres de gauche des contraintes
#LastModifiedIndex sera un entier ayant pour valeur l'indice de la derniere variable modifie de 0 a 1

function IsConsistent(CS::CurrentSolution)
   for j in 1:1:CS.NBconstraints
         if CS.Constraints[j][CS.LastModifiedIndex] == 1
            if CS.LastLeftMemberValue[j] ==  0
               CS.LastLeftMemberValue[j] = 1
            else
               return false,nothing
            end
         end
   end
   CS.CurrentObjectiveValue+=CS.Coefficients[CS.LastModifiedIndex]
   return true,CS
end
