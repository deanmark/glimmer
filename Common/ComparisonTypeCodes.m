classdef (Sealed) ComparisonTypeCodes
    % Enum of visual comparison type codes between two results
    
    properties  (Constant)
        Population = 1;
        Tau = 2;
        Beta = 3;
        Intensities = 4;
        IntensitiesTempUnit = 5;
        RadiationTemperature = 6;
        ExcitationTemperature = 7;

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
                    Result = 'Flux erg/cm2/s';                                        
                case ComparisonTypeCodes.IntensitiesTempUnit
                    Result = 'Flux K*km/s';                    
                case ComparisonTypeCodes.Tau
                    Result = 'Tau';                    
                case ComparisonTypeCodes.Beta
                    Result = 'Beta';
                case ComparisonTypeCodes.RadiationTemperature
                    Result = 'T radiation K';
                case ComparisonTypeCodes.ExcitationTemperature
                    Result = 'T excitation K';
                otherwise
                    ME = MException('VerifyInput:unknownComparisonTypeCode','Error in input. Comparison Type Code [%d] is unknown', ComparisonTypeCode);
                    throw(ME);
            end
        end
        
        function Result = ToCodeFromGUIFormat (ComparisonTypeCode)
            switch ComparisonTypeCode
                case 'Population'
                    Result = ComparisonTypeCodes.Population;
                case 'Flux erg/cm2/s'
                    Result = ComparisonTypeCodes.Intensities;
                case 'Flux K*km/s'
                    Result = ComparisonTypeCodes.IntensitiesTempUnit;
                case 'Tau'
                    Result = ComparisonTypeCodes.Tau;
                case 'Beta'
                    Result = ComparisonTypeCodes.Beta;                    
                case 'T radiation K'
                    Result = ComparisonTypeCodes.RadiationTemperature;
                case 'T excitation K'
                    Result = ComparisonTypeCodes.ExcitationTemperature;                    
                otherwise
                    ME = MException('VerifyInput:unknownLVGParameterCodes','Error in input. Comparison Type Code [%d] is unknown', ComparisonTypeCode);
                    throw(ME);
            end
        end
        
        function Result = GetLVGResultsValue(LVGResult, ComparisonTypeCode)
            switch ComparisonTypeCode
                
                case ComparisonTypeCodes.Population
                    Result = LVGResult.Population;
                case ComparisonTypeCodes.Intensities
                    Result = LVGResult.Intensities;
                case ComparisonTypeCodes.IntensitiesTempUnit
                    Result = LVGResult.IntensitiesTempUnit;
                case ComparisonTypeCodes.Tau
                    Result = LVGResult.FinalTauCoefficients;
                case ComparisonTypeCodes.Beta
                    Result = LVGResult.FinalBetaCoefficients;
                case ComparisonTypeCodes.RadiationTemperature
                    Result = LVGResult.RadiationTemeperature;
                case ComparisonTypeCodes.ExcitationTemperature
                    Result = LVGResult.ExcitationTemperature;
                otherwise
                    ME = MException('VerifyInput:unknownLVGParameterCode','Error in input. LVG Parameter Code [%d] is unknown', LVGParameterCode);
                    throw(ME);
            end
        end
        
        
    end
    
end