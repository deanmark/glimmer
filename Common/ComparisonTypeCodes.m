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
    
end