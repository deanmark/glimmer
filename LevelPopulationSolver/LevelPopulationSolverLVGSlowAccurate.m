classdef LevelPopulationSolverLVGSlowAccurate < LevelPopulationSolverLVG
    
    properties(SetAccess = private, Constant = true)
        
        m_changePercent = 0.1;
        
    end
   
    methods(Access=public)
       
        function LVG = LevelPopulationSolverLVGSlowAccurate(MoleculeData, BetaProvider, MaxIterations)
            
            LVG@LevelPopulationSolverLVG(MoleculeData, BetaProvider, MaxIterations);
           
        end
        
    end
    
    methods(Access=protected)
        
        function BetaGuess = interpolateNextBeta (obj, CurrentBetaGuess, BetaHistory, CurrentIteration)
            
            if (CurrentIteration > 1)
                BetaGuess = BetaHistory(:,:,CurrentIteration-1)*(1-obj.m_changePercent) + CurrentBetaGuess*obj.m_changePercent;
            else
                BetaGuess = CurrentBetaGuess;
            end
            
        end
        
    end
    
end