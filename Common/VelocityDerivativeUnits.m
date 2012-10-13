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

classdef (Sealed) VelocityDerivativeUnits
    % Enum of visual comparison type codes between two results
    
    properties  (Constant)
        %km s^-1 pc^-1
        kmSecParsec = 1;
        %km s^-1 cm^-1
        kmSecCm = 2;
        %s^-1
        sec = 3;
    end

    methods (Access = private)
        %private so that you can't instatiate.
        function out = VelocityDerivativeUnits
        end
    end
    
    methods (Access = public, Static=true)
        
        function conversion = ConversionFactorToCGS(VelocityDerivativeUnit)
            
            switch VelocityDerivativeUnit
                case VelocityDerivativeUnits.kmSecParsec
                    conversion = 10^5 / (3.08568025 * 10^18);
                case VelocityDerivativeUnits.kmSecCm
                    conversion = 10^5;
                case VelocityDerivativeUnits.sec
                    conversion = 1;
                    
            end
            
        end
        
        function description = GetHelpDescription(VelocityDerivativeUnit)
        
            [dvdrTypeNames,dvdrTypeValues, dvdrDescription] = FileIOHelper.GetClassConstants('VelocityDerivativeUnits',true);            
            description = dvdrDescription{dvdrTypeValues==VelocityDerivativeUnit};
            
        end
    end
    
end
