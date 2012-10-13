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

classdef (Sealed) PlotTypeCodes
    % Enum of beta types
    
    properties  (Constant)
        TwoDimensionContour = 1;
        ThreeDimensionContour  = 2;
    end
    
    methods (Access = private)
        %private so that you can't instatiate.
        function out = PlotTypeCodes
        end
    end
    
    methods (Access = public, Static=true)
        
        function p = GetFunctionPointer (PlotTypeCode)
            switch PlotTypeCode
                case PlotTypeCodes.TwoDimensionContour
                    p = str2func('contour');
                case PlotTypeCodes.ThreeDimensionContour
                    p = str2func('contour3');
                otherwise
                    ME = MException('VerifyInput:unknownPlotTypeCode','Error in input. Plot Type Code [%d] is unknown', PlotTypeCode);
                    throw(ME);
            end
        end
        
    end
    
end
