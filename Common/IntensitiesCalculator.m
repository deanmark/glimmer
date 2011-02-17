classdef IntensitiesCalculator < handle
    
    properties(SetAccess = private)
        
        m_einsteinCoefficients;
        m_transitionEnergies;
        m_frequencies;
        m_statisticalWeightsRatio;
        
    end
    
    methods(Access=public)
        
        function Inten = IntensitiesCalculator(MoleculeData)
            
            Inten.m_einsteinCoefficients = zeros(MoleculeData.MolecularLevels,1);
            Inten.m_transitionEnergies = zeros(MoleculeData.MolecularLevels,1);
            Inten.m_frequencies = zeros(MoleculeData.MolecularLevels,1);
            Inten.m_statisticalWeightsRatio = zeros(MoleculeData.MolecularLevels,1);
   
            HighLevels =  zeros(MoleculeData.MolecularLevels-1,1);
            HighLevels(:) = 2:MoleculeData.MolecularLevels;
            LowLevels = HighLevels - 1;
            
            Inten.m_einsteinCoefficients(2:end) = MoleculeData.EinsteinACoefficient(HighLevels, LowLevels);
            Inten.m_transitionEnergies(2:end) = MoleculeData.TransitionEnergy(HighLevels, LowLevels);
            Inten.m_frequencies(2:end) = MoleculeData.TransitionFrequency(HighLevels, LowLevels);
            Inten.m_statisticalWeightsRatio(2:end) = MoleculeData.StatisticalWeight(LowLevels)./MoleculeData.StatisticalWeight(HighLevels);
                        
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
        
        function Flux = CalculateFluxLTE(obj, Temperature)
           
            %(2 h nu^3 / c^2) (1/[exp(h nu / kT) - 1])
            
            Flux = (2 * Constants.h * obj.m_frequencies.^4 / Constants.c^2) .* (1./(exp(Constants.h * obj.m_frequencies / (Constants.k * Temperature))-1));
            Flux(1)=0;
            
        end

        function ExcitationTemp = CalculateExcitationTemperature(obj, LevelPopulation)
            
            levelPopulationRatio = zeros(size(LevelPopulation));
            levelPopulationRatio(2:end) = LevelPopulation(1:end-1)./LevelPopulation(2:end);
            ExcitationTemp = obj.m_transitionEnergies./(Constants.k * log(levelPopulationRatio./obj.m_statisticalWeightsRatio));
            
        end
        
    end
    
end