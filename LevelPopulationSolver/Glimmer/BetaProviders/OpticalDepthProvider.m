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

classdef OpticalDepthProvider < handle
    
    properties(SetAccess = private)
        
        m_tauMatrix;
        
    end
    
    methods(Access=public)
        
        function ODepth = OpticalDepthProvider(MoleculeData)
            
            ODepth.m_tauMatrix = ODepth.buildTauMatrix(MoleculeData);
            
        end
        
        function TauCoefficients = CalculateTauCoefficients(obj, Population, MoleculeDensity, VelocityDerivative)
            
            levels = size(Population,1);            
            MoleculeDensityArray = repmat(MoleculeDensity,levels,1);             
            TauCoefficients = ((obj.m_tauMatrix(1:levels,1:levels)/VelocityDerivative)*(Population)).*MoleculeDensityArray;
            
        end
        
    end
    
    methods(Access=private)
        
        function TauMatrix = buildTauMatrix (obj, MoleculeData)
            
            TauMatrix = zeros (MoleculeData.MolecularLevels, MoleculeData.MolecularLevels);
            
            for i = 2:MoleculeData.MolecularLevels
                
                A = MoleculeData.EinsteinACoefficient(i,i-1);
                gHigh = MoleculeData.StatisticalWeight(i);
                gLow = MoleculeData.StatisticalWeight(i-1);
                freq = MoleculeData.TransitionFrequency(i, i-1);
                
                constPart = (A*Constants.c^3)/(8*Constants.pi*freq^3);
                
                TauMatrix(i, i-1) = constPart*gHigh/gLow;
                TauMatrix(i, i) = - constPart;
                
            end
            
        end
        
    end
    
end
