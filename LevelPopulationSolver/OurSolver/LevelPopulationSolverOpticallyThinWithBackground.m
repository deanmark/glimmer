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

classdef LevelPopulationSolverOpticallyThinWithBackground < LevelPopulationSolverOpticallyThin
    
    properties(SetAccess = private)

        m_einsteinBMatrix;
       
    end
    
    methods(Access=public)
        
        function OThinWithBackgrnd = LevelPopulationSolverOpticallyThinWithBackground(MoleculeData, BackgroundTemperature)
            
            OThinWithBackgrnd@LevelPopulationSolverOpticallyThin(MoleculeData);
                        
            OThinWithBackgrnd.m_einsteinBMatrix = OThinWithBackgrnd.createEinsteinBMatrix(BackgroundTemperature);
            
        end
       
    end
    
    methods(Access=protected)
        
        function EinsteinMatrix = getEinsteinMatrix (obj, CollisionPartnerDensityIndex)
            
            EinsteinMatrix = obj.m_einsteinMatrix + obj.m_einsteinBMatrix;
            
        end
        
        function EinsteinMatrix = createEinsteinBMatrix (obj, BackgroundTemperature)
            
            einsteinBMatrix = obj.m_moleculeData.EinsteinBCoefficientMatrix();
            einsteinBMatrix = transpose(einsteinBMatrix);
                        
            [highLevels,lowLevels] = find(tril(einsteinBMatrix,-1)~=0);
            freq = obj.m_moleculeData.TransitionFrequency(highLevels,lowLevels);
            
            radiationFactor = ((2*Constants.h .* freq.^3) ./ Constants.c^2) .* (exp(Constants.h .* freq / (Constants.k * BackgroundTemperature))-1).^-1;
            radiationFactorMatrix = zeros(size(einsteinBMatrix));
            
            ind = sub2ind(size(radiationFactorMatrix),highLevels,lowLevels);
            radiationFactorMatrix(ind) = radiationFactor;
            
            ind = sub2ind(size(radiationFactorMatrix),lowLevels,highLevels);
            radiationFactorMatrix(ind) = radiationFactor;
            
            EinsteinMatrix = einsteinBMatrix.*radiationFactorMatrix;
            diagMembers = sum(EinsteinMatrix,1);
            EinsteinMatrix = EinsteinMatrix - diag(diagMembers);            
            
        end
        
    end    
    
end
