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
                        
            numLevels = numel(obj.m_einsteinCoefficients);
            numDensities = numel(LevelPopulation)/numLevels;
            
            if numel(ColumnDensities) ~= numDensities
                ME = MException('VerifyInput:invalidInputParameter', ...
                    'Error in input. ColumnDensities must be the same size as CollisionPartnerDensities. ColumnDensities contains [%g] elements, should contain [%g] elements', numel(ColumnDensities), numDensities);
                throw(ME);
            end
            
            repeatedEinsteinCoefficients = repmat(obj.m_einsteinCoefficients,[numDensities 1]);
            repeatedTransitionEnergies = repmat(obj.m_transitionEnergies,[numDensities 1]);
            repeatedDensities = repmat(ColumnDensities, [numLevels 1]);
            repeatedDensities = reshape(repeatedDensities, [numel(LevelPopulation) 1]);
            
            Intensities = (LevelPopulation.*repeatedEinsteinCoefficients.*repeatedTransitionEnergies.*BetaCoefficients.*repeatedDensities)/(4*Constants.pi);

        end
        
        function Intensities = CalculateIntensitiesOpticallyThin(obj, LevelPopulation)
            
            Intensities = (LevelPopulation.*obj.m_einsteinCoefficients.*obj.m_transitionEnergies)/(4*Constants.pi);
            
        end
        
    end
    
end