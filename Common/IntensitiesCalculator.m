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
        
        function Intensities = CalculateIntensitiesLVG(obj, LevelPopulation, TauCoefficients, ColumnDensities)
                        
            numLevels = size(LevelPopulation,1);
            numDensities = size(LevelPopulation,2);
            
            if numel(ColumnDensities) ~= numDensities
                ME = MException('VerifyInput:invalidInputParameter', ...
                    'Error in input. ColumnDensities must be the same size as CollisionPartnerDensities. ColumnDensities contains [%g] elements, should contain [%g] elements', numel(ColumnDensities), numDensities);
                throw(ME);
            end
            
            repeatedEinsteinCoefficients = repmat(obj.m_einsteinCoefficients,[1 numDensities]);
            repeatedTransitionEnergies = repmat(obj.m_transitionEnergies,[1 numDensities]);
            repeatedDensities = repmat(ColumnDensities, [numLevels 1]);
            
            smallNumbersLogicalIndex = (-10^-5 < TauCoefficients) & (TauCoefficients < 10^-5);
            
            BetaCoefficients = zeros(size(TauCoefficients));
            %use taylor expansion for small numbers. because matlab doesn't
            %handle small numbers well
            BetaCoefficients(smallNumbersLogicalIndex) = 1-0.5*TauCoefficients(smallNumbersLogicalIndex);
            
            BetaCoefficients(~smallNumbersLogicalIndex) = (1-exp(-TauCoefficients(~smallNumbersLogicalIndex)))./TauCoefficients(~smallNumbersLogicalIndex);            
            
            Intensities = (LevelPopulation.*repeatedEinsteinCoefficients.*repeatedTransitionEnergies.*BetaCoefficients.*repeatedDensities)/(4*Constants.pi);

        end
        
        function Intensities = CalculateIntensitiesOpticallyThin(obj, LevelPopulation)
            
            Intensities = (LevelPopulation.*obj.m_einsteinCoefficients.*obj.m_transitionEnergies)/(4*Constants.pi);
            
        end
        
    end
    
end