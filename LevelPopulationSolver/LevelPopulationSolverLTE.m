classdef LevelPopulationSolverLTE < LevelPopulationSolverOpticallyThin
    
    properties(SetAccess = private)

        m_dummyEinsteinMatrix;
       
    end
    
    methods(Access=public)
        
        function LTE = LevelPopulationSolverLTE(MoleculeData)
            
            LTE@LevelPopulationSolverOpticallyThin(MoleculeData);
                        
            LTE.m_dummyEinsteinMatrix = zeros(size(LTE.m_einsteinMatrix));
            
        end
       
    end
    
    methods(Access=protected)
        
        function EinsteinMatrix = getEinsteinMatrix (obj, CollisionPartnerDensity)
            EinsteinMatrix = obj.m_dummyEinsteinMatrix;
        end
        
    end
end