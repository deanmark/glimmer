classdef LVGSolverAlgorithmParameters < handle
    %LVGSOLVERINITIALIZEPARAMETERS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess = public)
        
        MinIterations;
        MaxIterations;
        ChangePercent;
        ConvergenceThreshold;
        SignificantPopulationThreshold;
        
    end
    
    methods(Access = public)
        
        function Params = LVGSolverAlgorithmParameters()
            
            %default parameters;
            Params.MinIterations = 4;
            Params.MaxIterations = 1000;
            Params.ChangePercent = 0.01;
            Params.ConvergenceThreshold = 0.0001;
            Params.SignificantPopulationThreshold = 0.001;
            
        end
        
    end
    
end