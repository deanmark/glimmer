classdef LevelPopulationSolverLVGSlowAccurate < LevelPopulationSolverLVG
    
    methods(Access=public)
       
        function LVG = LevelPopulationSolverLVGSlowAccurate(MoleculeData, BetaProvider, LVGAlgorithmParameters)
            
            LVG@LevelPopulationSolverLVG(MoleculeData, BetaProvider, LVGAlgorithmParameters);
            
        end
        
    end
    
    methods(Access=protected)
        
        function BetaGuess = interpolateNextBeta (obj, CurrentBetaGuess, BetaHistory, CurrentIteration)
            
            if (CurrentIteration > 1)
                BetaGuess = BetaHistory(:,:,CurrentIteration-1)*(1-obj.m_algorithmParameters.ChangePercent) + CurrentBetaGuess*obj.m_algorithmParameters.ChangePercent;
            else
                BetaGuess = CurrentBetaGuess;
            end
            
        end
        
    end
    
end