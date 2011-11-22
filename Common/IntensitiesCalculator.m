classdef IntensitiesCalculator < handle
    
    properties(SetAccess = private)
        
        m_einsteinCoefficients;
        m_transitionEnergies;
        m_frequencies;
        m_statisticalWeightsRatio;
        
        m_expandingSphereBetaProvider;
        
    end
        
    methods(Access=public)
        
        function Inten = IntensitiesCalculator(MoleculeData, IncludeBackgroundRadiation, BackgroundTemperature)
            
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
            
            Inten.m_expandingSphereBetaProvider = ExpandingSphereBetaProvider(MoleculeData, false, IncludeBackgroundRadiation, BackgroundTemperature);
                        
        end
        
        function Intensities = CalculateIntensitiesLVG(obj, LevelPopulation, TauCoefficients, MoleculeAbundanceRatio, CollisionPartnerColumnDensity)
                        
            numDensities = size(LevelPopulation,2);
            
            repeatedEinsteinCoefficients = repmat(obj.m_einsteinCoefficients,[1 numDensities]);
            repeatedTransitionEnergies = repmat(obj.m_transitionEnergies,[1 numDensities]);
            
            BetaCoefficients = obj.m_expandingSphereBetaProvider.TauCoefficientsToBetaCoefficients(TauCoefficients);
            
            if (obj.m_expandingSphereBetaProvider.IncludeBackgroundRadiation)
                BetaCoefficients = BetaCoefficients .* obj.m_expandingSphereBetaProvider.m_cosmicBackgroundProvider.BackgroundRadiationFactor(LevelPopulation);
            end
            
            Intensities = (LevelPopulation.*repeatedEinsteinCoefficients.*repeatedTransitionEnergies.*BetaCoefficients*MoleculeAbundanceRatio*CollisionPartnerColumnDensity)/(4*Constants.pi);

        end
        
        function Intensities = CalculateIntensitiesOpticallyThin(obj, LevelPopulation, MoleculeAbundanceRatio)
            
            Intensities = (LevelPopulation.*obj.m_einsteinCoefficients.*obj.m_transitionEnergies*MoleculeAbundanceRatio)/(4*Constants.pi);
            
        end
        
        function Flux = CalculateFluxLTE(obj, Temperature, MoleculeAbundanceRatio)

            %(2 h nu^3 / c^2) (1/[exp(h nu / kT) - 1])
            
            Flux = (2 * Constants.h * obj.m_frequencies.^ 3 * MoleculeAbundanceRatio / Constants.c^2) .* (1./(exp(Constants.h * obj.m_frequencies / (Constants.k * Temperature))-1));
            Flux(1)=0;
            
        end

        function ExcitationTemp = CalculateExcitationTemperature(obj, LevelPopulation)
            
            levelPopulationRatio = zeros(size(LevelPopulation));
            levelPopulationRatio(2:end) = LevelPopulation(1:end-1)./LevelPopulation(2:end);
            ExcitationTemp = obj.m_transitionEnergies./(Constants.k * log(levelPopulationRatio./obj.m_statisticalWeightsRatio));
            
        end
        
        function IntensityTemperatureUnits = CalculateIntensityInTemperatureUnits (obj, LevelPopulation, TauCoefficients, MoleculeAbundanceRatio, CollisionPartnerColumnDensity)
        
            Intensity = obj.CalculateIntensitiesLVG(LevelPopulation, TauCoefficients, MoleculeAbundanceRatio, CollisionPartnerColumnDensity);            
            IntensityTemperatureUnits = (Intensity ./ (obj.m_frequencies .^ 3)) * Constants.c ^ 3 / (2 * Constants.k);
            
        end
        
        function RadiationTemperature = CalculateRadiationTemperature (obj, LevelPopulation, TauCoefficients)
        
            ExcitationTemperature = obj.CalculateExcitationTemperature(LevelPopulation);
            
            RadiationTemperature = ExcitationTemperature .* (1-exp(-TauCoefficients))  +  obj.m_expandingSphereBetaProvider.m_cosmicBackgroundProvider.BackgroundTemperature * exp(-TauCoefficients);
            RadiationTemperature(1)=0;
            
            
        end
        
                
    end
    
end