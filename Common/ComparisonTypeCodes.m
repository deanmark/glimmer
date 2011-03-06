classdef (Sealed) ComparisonTypeCodes
    % Enum of visual comparison type codes between two results
    
    properties  (Constant)
        Population = 1;
        Intensities = 2;
        Tau = 3;
        Beta = 4;
    end
    
    methods (Access = private)
        %private so that you can't instatiate.
        function out = ComparisonTypeCodes
        end
    end
    
    methods (Access = public, Static=true)
        
        function Result = ToStringGUIFormat (ComparisonTypeCode)
            switch ComparisonTypeCode
                case ComparisonTypeCodes.Population
                    Result = 'Population';                    
                case ComparisonTypeCodes.Intensities
                    Result = 'Intensities';                    
                case ComparisonTypeCodes.Tau
                    Result = 'Tau';                    
                case ComparisonTypeCodes.Beta
                    Result = 'Beta';
                otherwise
                    ME = MException('VerifyInput:unknownComparisonTypeCode','Error in input. Comparison Type Code [%d] is unknown', ComparisonTypeCode);
                    throw(ME);
            end
        end
        
        function Result = ToCodeFromGUIFormat (ComparisonTypeCode)
            switch ComparisonTypeCode
                case 'Population'
                    Result = ComparisonTypeCodes.Population;
                case 'Intensities'
                    Result = ComparisonTypeCodes.Intensities;
                case 'Tau'
                    Result = ComparisonTypeCodes.Tau;
                case 'Beta'
                    Result = ComparisonTypeCodes.Beta;
                otherwise
                    ME = MException('VerifyInput:unknownLVGParameterCodes','Error in input. Comparison Type Code [%d] is unknown', ComparisonTypeCode);
                    throw(ME);
            end
        end
        
        function Result = GetLVGResultsValue(Result, ComparisonTypeCode)
            switch ComparisonTypeCode
                
                case ComparisonTypeCodes.Population
                    Result = Result.Population;
                case ComparisonTypeCodes.Intensities
                    Result = Result.Intensities;
                case ComparisonTypeCodes.Tau
                    Result = Result.FinalTauCoefficients;
                case ComparisonTypeCodes.Beta
                    Result = Result.FinalBetaCoefficients;
                    
                otherwise
                    ME = MException('VerifyInput:unknownLVGParameterCode','Error in input. LVG Parameter Code [%d] is unknown', LVGParameterCode);
                    throw(ME);
            end
        end
        
        
    end
    
end