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