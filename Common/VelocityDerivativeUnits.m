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