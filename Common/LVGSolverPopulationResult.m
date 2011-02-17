classdef LVGSolverPopulationResult < handle
    
    properties (Access = public)
        
        OriginalRequest;
        
        Population; 
        FinalBetaCoefficients; 
        FinalTauCoefficients;
        %Intensity per column density
        Intensities;
        ExcitationTemperature;
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
        
        function ReqCopy = Copy (rhs)
            
            p = inputParser();
            p.addRequired('rhs', @(x)isa(x,'LVGSolverPopulationResult'));
            p.parse(rhs);
            
            ReqCopy = LVGSolverPopulationResult();
            
            fns = properties(rhs);
            for i=1:length(fns)
                ReqCopy.(fns{i}) = rhs.(fns{i});
            end
            
        end
        
    end
    
end

