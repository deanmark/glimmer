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

classdef (Sealed) DisplayDataCodes
    % Enum of beta types
    
    properties  (Constant)
        Ratios = 1;
        Nominator = 2;
        Denominator = 3;
    end

    methods (Access = private)
        %private so that you can't instatiate.
        function out = DisplayDataCodes
        end
    end
    
    methods (Access = public, Static=true)
        
        function Result = ToStringGUIFormat (DisplayDataCode)
            switch DisplayDataCode
                case DisplayDataCodes.Ratios
                    Result = 'Ratios';
                case DisplayDataCodes.Nominator
                    Result = 'Nominator';                    
                case DisplayDataCodes.Denominator
                    Result = 'Denominator';                    
                otherwise
                    ME = MException('VerifyInput:unknownDisplayDataCode','Error in input. Display Data Code [%d] is unknown', DisplayDataCode);
                    throw(ME);
            end
        end
        
        function Result = ToCodeFromGUIFormat (DisplayDataCode)
            switch DisplayDataCode
                case 'Ratios'
                    Result = DisplayDataCodes.Ratios;
                case 'Nominator'
                    Result = DisplayDataCodes.Nominator;
                case 'Denominator'
                    Result = DisplayDataCodes.Denominator;
                otherwise
                    ME = MException('VerifyInput:unknownDisplayDataCode','Error in input. Display Data Code [%d] is unknown', DisplayDataCode);
                    throw(ME);
            end
        end
        
    end
    
end
