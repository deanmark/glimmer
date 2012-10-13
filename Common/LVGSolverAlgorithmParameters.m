%{
GLIMMER is a visual LVG (Large Velocity Gradient) analysis tool.

Copyright (C) 2012  Dean Mark <deanmark at gmail>, 
		Prof. Amiel Sternberg <amiel at wise.tau.ac.il>, 
		Department of Astrophysics, Tel-Aviv University

Documentation for the program is posted at http://deanmark.github.com/glimmer/

This file is part of GLIMMER.

GLIMMER is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

GLIMMER is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
%}

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
