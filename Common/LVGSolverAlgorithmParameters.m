classdef LVGSolverAlgorithmParameters < handle
    
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
        
        function Result = DefaultInitialRunParamsHighExcitation ()
            
            Result = LVGSolverAlgorithmParameters();
            Result.MinIterations = 4;
            Result.MaxIterations = 1500;
            Result.ChangePercent = 1e-2;
            Result.ConvergenceThreshold = 1e-5;
            Result.SignificantPopulationThreshold = 0.001;
            
        end
        
        function Result = DefaultInitialRunParamsLowExcitation ()
            
            Result = LVGSolverAlgorithmParameters();
            Result.MinIterations = 4;
            Result.MaxIterations = 1500;
            Result.ChangePercent = 1e-3;
            Result.ConvergenceThreshold = 1e-5;
            Result.SignificantPopulationThreshold = 0.001;
            
        end
        
        function Result = DefaultConfirmationRunParamsLowExcitation ()
            
            Result = LVGSolverAlgorithmParameters();
            Result.MinIterations = 4;
            Result.MaxIterations = 5000;
            Result.ChangePercent = 1e-5;
            Result.ConvergenceThreshold = 1e-6;
            Result.SignificantPopulationThreshold = 0.001;
            
        end
        
        function Result = DefaultConfirmationRunParamsHighExcitation ()
            
            Result = LVGSolverAlgorithmParameters();
            Result.MinIterations = 4;
            Result.MaxIterations = 3000;
            Result.ChangePercent = 1e-4;
            Result.ConvergenceThreshold = 1e-6;
            Result.SignificantPopulationThreshold = 0.001;
            
        end
        
    end
    
end