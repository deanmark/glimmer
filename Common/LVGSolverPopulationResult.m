classdef LVGSolverPopulationResult < handle
    
    properties (Access = public)
        
        Population; 
        FinalBetaCoefficients; 
        Converged; 
        Iterations; 
        MaxDiffPercentHistory; 
        PopulationHistory; 
        TauHistory; 
        BetaHistory;    
        
    end
    
    methods(Access=public)
        
        function Req = LVGSolverPopulationResult()
            
        end
        
    end
    
end

