classdef IntensitiesCalculator < handle
    
    properties(SetAccess = private)
        
        m_einsteinCoefficients;
        m_transitionEnergies;
        
    end
    
    methods(Access=public)
        
        function Inten = IntensitiesCalculator(MoleculeData)
            
            Inten.m_einsteinCoefficients = zeros(MoleculeData.MolecularLevels,1);
            Inten.m_transitionEnergies = zeros(MoleculeData.MolecularLevels,1);
   
            for i=2:MoleculeData.MolecularLevels
                
                Inten.m_einsteinCoefficients(i) = MoleculeData.EinsteinACoefficient(i, i-1);
                Inten.m_transitionEnergies(i) = MoleculeData.TransitionEnergy(i, i-1);
                
            end
            
        end
        
        function Intensities = CalculateIntensitiesLVG(obj, LevelPopulation, BetaCoefficients, ColumnDensities)
            
            Intensities = (LevelPopulation.*obj.m_einsteinCoefficients.*obj.m_transitionEnergies.*BetaCoefficients*ColumnDensities)/(4*Constants.pi);

        end
        
        function Intensities = CalculateIntensitiesOpticallyThin(obj, LevelPopulation)
            
            Intensities = (LevelPopulation.*obj.m_einsteinCoefficients.*obj.m_transitionEnergies)/(4*Constants.pi);
            
        end
        
    end
    
end