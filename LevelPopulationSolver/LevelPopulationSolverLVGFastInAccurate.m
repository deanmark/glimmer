classdef LevelPopulationSolverLVGFastInAccurate < LevelPopulationSolverLVG
       
    methods(Access=public)
       
        function LVG = LevelPopulationSolverLVGFastInAccurate(MoleculeData, BetaProvider, MaxIterations)
            
            LVG@LevelPopulationSolverLVG(MoleculeData, BetaProvider, MaxIterations);
           
        end
        
    end
    
    methods(Access=protected)
        
        function PopulationGuess = interpolateNextPopulation (obj, CurrentPopulationGuess, PopulationHistory, CurrentIteration)
            
            if (CurrentIteration >= 3)
                
                diff1Back = obj.calculateMeanDifferenceRatio(PopulationHistory(:,:,CurrentIteration-1), CurrentPopulationGuess, true);
                diff2Back = obj.calculateMeanDifferenceRatio(PopulationHistory(:,:,CurrentIteration-2), CurrentPopulationGuess, true);
                
                if (diff1Back > diff2Back)
                    PopulationGuess = (CurrentPopulationGuess+PopulationHistory(:,:,CurrentIteration-1))/2;
                else
                    PopulationGuess = CurrentPopulationGuess;
                end
                
            else
                PopulationGuess = CurrentPopulationGuess;
            end
            
        end
        
    end
    
end