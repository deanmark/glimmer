classdef (Sealed) LVGParameterCodes
    
    properties  (Constant)
        Temperature = 1;
        CollisionPartnerDensity = 2;
        VelocityDerivative = 3;
        MoleculeAbundanceRatio = 4;
        ConstantNpartnerBydVdR = 5;
    end

    methods (Access = private)
        %private so that you can't instatiate.
        function out = LVGParameterCodes
        end
    end
    
end