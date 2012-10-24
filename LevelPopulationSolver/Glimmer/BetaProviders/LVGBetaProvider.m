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

classdef LVGBetaProvider < handle
    
    properties (SetAccess = public)
        
        IgnoreNegativeTau;
        IncludeBackgroundRadiation;
        BackgroundTemperature;
        
    end
    
    properties (SetAccess = private)
        
        m_cosmicBackgroundProvider;
        m_opticalDepthProvider;
        
    end
    
    methods(Access=public)
        
        function BetaProvider = LVGBetaProvider(MoleculeData, IgnoreNegativeTau, IncludeBackgroundRadiation, BackgroundTemperature)
            
            BetaProvider.IgnoreNegativeTau = IgnoreNegativeTau;
            BetaProvider.IncludeBackgroundRadiation = IncludeBackgroundRadiation;
            BetaProvider.BackgroundTemperature = BackgroundTemperature;
            BetaProvider.m_opticalDepthProvider = OpticalDepthProvider(MoleculeData);
            
            if (IncludeBackgroundRadiation)
                BetaProvider.m_cosmicBackgroundProvider = CosmicBackgroundProvider(MoleculeData, BackgroundTemperature);
            end
            
        end
        
    end
    
        
    methods (Access=public)
        
        function [BetaCoefficients, TauCoefficients] = CalculateBetaCoefficients (obj, Population, MoleculeDensity, VelocityDerivative)
            
            TauCoefficients = obj.m_opticalDepthProvider.CalculateTauCoefficients(Population, MoleculeDensity, VelocityDerivative);
            
            if (obj.IgnoreNegativeTau)
                TauCoefficients(TauCoefficients < 0) = 0;
            end
            
            BetaCoefficients = obj.TauCoefficientsToBetaCoefficients (TauCoefficients);
            
            if (obj.IncludeBackgroundRadiation)
                BetaCoefficients = BetaCoefficients .* obj.m_cosmicBackgroundProvider.BackgroundRadiationFactor(Population);
            end
            
            BetaCoefficients(1) = 0;
            
        end
        
    end
    
    methods (Access=public, Abstract)
        
        BetaCoefficients = TauCoefficientsToBetaCoefficients (TauCoefficients);
        
    end

    
end
