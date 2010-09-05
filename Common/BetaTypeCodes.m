classdef (Sealed) BetaTypeCodes
    % Enum of beta types
    
    properties  (Constant)
        ExpandingSphere = 1;
        UniformSphere = 2;
        HomogeneousSlab = 3;
    end

    methods (Access = private)
        %private so that you can't instatiate.
        function out = BetaTypeCodes
        end
    end
    
end