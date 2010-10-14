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
        
        function Intensities = CalculateIntensitiesLVG(obj, LevelPopulation, TauCoefficients)
                        
            numDensities = size(LevelPopulation,2);
            
            repeatedEinsteinCoefficients = repmat(obj.m_einsteinCoefficients,[1 numDensities]);
            repeatedTransitionEnergies = repmat(obj.m_transitionEnergies,[1 numDensities]);
            
            smallNumbersLogicalIndex = (-10^-5 < TauCoefficients) & (TauCoefficients < 10^-5);
            
            BetaCoefficients = zeros(size(TauCoefficients));
            %use taylor expansion for small numbers. because matlab doesn't
            %handle small numbers well
            BetaCoefficients(smallNumbersLogicalIndex) = 1-0.5*TauCoefficients(smallNumbersLogicalIndex);
            
            BetaCoefficients(~smallNumbersLogicalIndex) = (1-exp(-TauCoefficients(~smallNumbersLogicalIndex)))./TauCoefficients(~smallNumbersLogicalIndex);            
            
            Intensities = (LevelPopulation.*repeatedEinsteinCoefficients.*repeatedTransitionEnergies.*BetaCoefficients)/(4*Constants.pi);

        end
        
        function Intensities = CalculateIntensitiesOpticallyThin(obj, LevelPopulation)
            
            Intensities = (LevelPopulation.*obj.m_einsteinCoefficients.*obj.m_transitionEnergies)/(4*Constants.pi);
            
        end
        
    end
    
end