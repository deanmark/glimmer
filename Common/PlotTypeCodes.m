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