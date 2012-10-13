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

classdef LevelPopulationSolverLTE < LevelPopulationSolverOpticallyThin
    
    properties(SetAccess = private)

        m_dummyEinsteinMatrix;
       
    end
    
    methods(Access=public)
        
        function LTE = LevelPopulationSolverLTE(MoleculeData)
            
            LTE@LevelPopulationSolverOpticallyThin(MoleculeData);
                        
            LTE.m_dummyEinsteinMatrix = zeros(size(LTE.m_einsteinMatrix));
            
        end
       
    end
    
    methods(Access=protected)
        
        function EinsteinMatrix = getEinsteinMatrix (obj, CollisionPartnerDensityIndex)
            EinsteinMatrix = obj.m_dummyEinsteinMatrix;
        end
        
    end
end
