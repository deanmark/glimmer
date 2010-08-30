classdef LevelPopulationSolverOpticallyThinWithBackground < LevelPopulationSolverOpticallyThin
    
    properties(SetAccess = private)

        m_einsteinBMatrix;
       
    end
    
    methods(Access=public)
        
        function OThinWithBackgrnd = LevelPopulationSolverOpticallyThinWithBackground(MoleculeData, BackgroundTemperature)
            
            OThinWithBackgrnd@LevelPopulationSolverOpticallyThin(MoleculeData);
                        
            OThinWithBackgrnd.m_einsteinBMatrix = OThinWithBackgrnd.createEinsteinBMatrix(BackgroundTemperature);
            
        end
       
    end
    
    methods(Access=protected)
        
        function EinsteinMatrix = getEinsteinMatrix (obj, CollisionPartnerDensity)
            
            EinsteinMatrix = obj.m_einsteinMatrix + obj.m_einsteinBMatrix;
            
        end
        
        function EinsteinMatrix = createEinsteinBMatrix (obj, BackgroundTemperature)
            
            einsteinBMatrix = obj.m_moleculeData.EinsteinBCoefficientMatrix();
            einsteinBMatrix = transpose(einsteinBMatrix);
                        
            [highLevels,lowLevels] = find(tril(einsteinBMatrix,-1)~=0);
            freq = obj.m_moleculeData.TransitionFrequency(highLevels,lowLevels);
            
            radiationFactor = ((2*Constants.h .* freq.^3) ./ Constants.c^2) .* (exp(Constants.h .* freq / (Constants.k * BackgroundTemperature))-1).^-1;
            radiationFactorMatrix = zeros(size(einsteinBMatrix));
            
            ind = sub2ind(size(radiationFactorMatrix),highLevels,lowLevels);
            radiationFactorMatrix(ind) = radiationFactor;
            
            ind = sub2ind(size(radiationFactorMatrix),lowLevels,highLevels);
            radiationFactorMatrix(ind) = radiationFactor;
            
            EinsteinMatrix = einsteinBMatrix.*radiationFactorMatrix;
            diagMembers = sum(EinsteinMatrix,1);
            EinsteinMatrix = EinsteinMatrix - diag(diagMembers);            
            
        end
        
    end    
    
end