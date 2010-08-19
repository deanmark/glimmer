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
            
        end
        
    end
    
    methods(Access=public, Static=true)
       
        function Result = DefaultInitialRunParams ()
        
            Result = LVGSolverAlgorithmParameters();
            Result.MinIterations = 4;
            Result.MaxIterations = 1500;
            Result.ChangePercent = 0.01;
            Result.ConvergenceThreshold = 0.0001;
            Result.SignificantPopulationThreshold = 0.001;
            
        end
                
        function Result = DefaultConfirmationRunParams ()
        
            Result = LVGSolverAlgorithmParameters();
            Result.MinIterations = 4;
            Result.MaxIterations = 5000;
            Result.ChangePercent = 0.000001;
            Result.ConvergenceThreshold = 0.0001;
            Result.SignificantPopulationThreshold = 0.001;
            
        end
                
    end
    
end