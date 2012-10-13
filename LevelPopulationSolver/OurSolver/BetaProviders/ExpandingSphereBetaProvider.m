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

classdef ExpandingSphereBetaProvider < LVGBetaProvider
    
    methods(Access=public)
        
        function BetaProvider = ExpandingSphereBetaProvider(MoleculeData, IgnoreNegativeTau, IncludeBackgroundRadiation, BackgroundTemperature)
            
            BetaProvider@LVGBetaProvider(MoleculeData, IgnoreNegativeTau, IncludeBackgroundRadiation, BackgroundTemperature);
            
        end
        
    end
    
    methods(Access=public)
        
        function BetaCoefficients = TauCoefficientsToBetaCoefficients (obj, TauCoefficients)
            
            smallNumbersLogicalIndex = (-10^-5 < TauCoefficients) & (TauCoefficients < 10^-5);
            
            BetaCoefficients = zeros(size(TauCoefficients));
            %use taylor expansion for small numbers. because matlab doesn't
            %handle small numbers well
            BetaCoefficients(smallNumbersLogicalIndex) = 1-0.5*TauCoefficients(smallNumbersLogicalIndex);
            
            x = TauCoefficients(~smallNumbersLogicalIndex);
            BetaCoefficients(~smallNumbersLogicalIndex) = (1-exp(-x))./x;
                        
        end
        
    end
    
end
