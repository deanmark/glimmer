classdef IntensitiesHelper
    %INTENSITIESHELPER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods(Static, Access=public)
        
        function ModifiedResult = PinColumnDensityToProperty(LVGParameterCode, ColumnDensityArray, PopulationResult)
            
            ModifiedResult = PopulationResult.Copy();
            request = PopulationResult.OriginalRequest;
            
            switch LVGParameterCode
                case LVGParameterCodes.Temperature
                    for i=1:numel(request.Temperature)
                        ModifiedResult.Intensities(:,i,:,:,:) = ModifiedResult.Intensities(:,i,:,:,:)*ColumnDensityArray(i);
                    end
                case LVGParameterCodes.CollisionPartnerDensity
                    for i=1:numel(request.CollisionPartnerDensities)
                        ModifiedResult.Intensities(:,:,i,:,:) = ModifiedResult.Intensities(:,:,i,:,:)*ColumnDensityArray(i);
                    end
                case LVGParameterCodes.VelocityDerivative
                    for i=1:numel(request.VelocityDerivative)
                        ModifiedResult.Intensities(:,:,:,i,:) = ModifiedResult.Intensities(:,:,:,i,:)*ColumnDensityArray(i);
                    end
                case LVGParameterCodes.MoleculeAbundanceRatio
                    for i=1:numel(request.MoleculeAbundanceRatios)
                        ModifiedResult.Intensities(:,:,:,:,i) = ModifiedResult.Intensities(:,:,:,:,i)*ColumnDensityArray(i);
                    end
                otherwise
                    ME = MException('VerifyInput:unknownLVGParameterCode','Error in input. LVG Parameter Code [%d] is unknown', LVGParameterCode);
                    throw(ME);                    
            end
            
        end
        
    end
    
end

