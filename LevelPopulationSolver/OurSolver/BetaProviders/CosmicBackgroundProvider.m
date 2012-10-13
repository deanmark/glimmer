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

classdef CosmicBackgroundProvider < handle
    
    properties (SetAccess = private)
        
        m_backgroundVector;
        m_backgroundConstants;
        BackgroundTemperature;
        
    end
    
    methods(Access=public)
        
        function Cosmic = CosmicBackgroundProvider(MoleculeData, BackgroundTemperature)
            
            Cosmic.initializeBackgroundVector(MoleculeData, BackgroundTemperature);
            Cosmic.BackgroundTemperature = BackgroundTemperature;
            
        end
        
        function BackgroundRadiationFactor = BackgroundRadiationFactor(obj, Population)
            
            levels = size(Population,1);
            popRatios = zeros(size(Population));
            popRatios(2:end,:) = Population(1:(end-1),:)./Population(2:end,:);
            
            BackgroundRadiationFactor = repmat(obj.m_backgroundConstants(1:levels),1,size(Population,2)) + repmat(obj.m_backgroundVector(1:levels),1,size(Population,2)).*popRatios;
            
            %The modification of the original beta should be within the
            %range of 0 to 1. Sometimes the calculation goes wrong and this
            %does not happen. In these cases we set the beta multiplication
            %factor to 1. In the stable solution this should not occur.
            BackgroundRadiationFactor(BackgroundRadiationFactor > 1 | isnan(BackgroundRadiationFactor) | isinf(BackgroundRadiationFactor)) = 1;
            BackgroundRadiationFactor(BackgroundRadiationFactor < 0) = 1e-4;            
             
        end
        
    end
    
    methods(Access=private)
       
        function initializeBackgroundVector (obj, MoleculeData, BackgroundTemperature)
            
            exponents = zeros(MoleculeData.MolecularLevels,1);
            statisticalWeightRatios = zeros(MoleculeData.MolecularLevels,1);
            
            for i=2:MoleculeData.MolecularLevels
                
                exponents(i) = exp(MoleculeData.TransitionEnergy(i, i-1)/(Constants.k*BackgroundTemperature));
                statisticalWeightRatios(i) = MoleculeData.StatisticalWeight(i)/MoleculeData.StatisticalWeight(i-1);
                
            end

            obj.m_backgroundConstants = 1+1./(exponents-1);
            obj.m_backgroundVector = - statisticalWeightRatios./(exponents-1);
            
        end
        
    end
    
end
