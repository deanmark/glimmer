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

classdef (Sealed) RunTypeCodes
    % Enum of run type codes
    
    properties  (Constant)
        LVG = 1;
        OpticallyThin = 2;
        LTE = 3;
        OpticallyThinWithBackground = 4;
        Radex = 5;
    end
    
    methods (Access = private)
        %private so that you can't instatiate.
        function out = RunTypeCodes
        end
    end
    
    methods (Access = public, Static=true)
        
        function Result = ToStringGUIFormat (RunTypeCode)
            switch RunTypeCode
                case RunTypeCodes.LVG
                    Result = 'LVG';
                case RunTypeCodes.OpticallyThin
                    Result = 'Optically Thin';
                case RunTypeCodes.LTE
                    Result = 'LTE';
                case RunTypeCodes.OpticallyThinWithBackground
                    Result = 'Optically Thin With Background';
                case RunTypeCodes.Radex
                    Result = 'Radex';
                otherwise
                    ME = MException('VerifyInput:unknownRunTypeCode','Error in input. Run Type Code [%d] is unknown', RunTypeCode);
                    throw(ME);
            end
        end
        
    end
    
end
