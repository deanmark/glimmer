classdef LevelPopulationSolverLVGSlowAccurate < LevelPopulationSolverLVG
    
    properties(SetAccess = private)
        
        m_changePercent;
        
    end
   
    methods(Access=public)
       
        function LVG = LevelPopulationSolverLVGSlowAccurate(MoleculeData, BetaProvider, MaxIterations, ChangePercent)
            
            LVG@LevelPopulationSolverLVG(MoleculeData, BetaProvider, MaxIterations);
            
            if isempty(ChangePercent)
                ChangePercent = 0.1;
            end
                
            LVG.m_changePercent = ChangePercent;
           
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