classdef (Sealed) RunTypeCodes
    % Enum of beta types
    
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
    
end