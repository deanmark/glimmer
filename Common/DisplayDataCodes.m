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