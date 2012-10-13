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

classdef LVGSolverPopulationResult < handle
    
    properties (Access = public)
        
        OriginalRequest;
        
        Population; 
        FinalBetaCoefficients; 
        FinalTauCoefficients;
        %Intensity per column density
        Intensities;
        IntensitiesTempUnit;
        ExcitationTemperature;        
        RadiationTemeperature;
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

