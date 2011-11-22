classdef LVGBetaProvider < handle
    
    properties (SetAccess = public)
        
        IgnoreNegativeTau;
        IncludeBackgroundRadiation;
        BackgroundTemperature;
        
    end
    
    properties (SetAccess = private)
        
        m_cosmicBackgroundProvider;
        m_opticalDepthProvider;
        
    end
    
    methods(Access=public)
        
        function BetaProvider = LVGBetaProvider(MoleculeData, IgnoreNegativeTau, IncludeBackgroundRadiation, BackgroundTemperature)
            
            BetaProvider.IgnoreNegativeTau = IgnoreNegativeTau;
            BetaProvider.IncludeBackgroundRadiation = IncludeBackgroundRadiation;
            BetaProvider.BackgroundTemperature = BackgroundTemperature;
            BetaProvider.m_opticalDepthProvider = OpticalDepthProvider(MoleculeData);
            
            if (IncludeBackgroundRadiation)
                BetaProvider.m_cosmicBackgroundProvider = CosmicBackgroundProvider(MoleculeData, BackgroundTemperature);
            end
            
        end
        
    end
    
        
    methods (Access=public)
        
        function [BetaCoefficients, TauCoefficients] = CalculateBetaCoefficients (obj, Population, MoleculeDensity, VelocityDerivative)
            
            TauCoefficients = obj.m_opticalDepthProvider.CalculateTauCoefficients(Population, MoleculeDensity, VelocityDerivative);
            
            if (obj.IgnoreNegativeTau)
                TauCoefficients(TauCoefficients < 0) = 0;
            end
            
            BetaCoefficients = obj.TauCoefficientsToBetaCoefficients (TauCoefficients);
            
            if (obj.IncludeBackgroundRadiation)
                BetaCoefficients = BetaCoefficients .* obj.m_cosmicBackgroundProvider.BackgroundRadiationFactor(Population);
            end
            
            BetaCoefficients(1) = 0;
            
        end
        
    end
    
    methods (Access=public, Abstract)
        
        BetaCoefficients = TauCoefficientsToBetaCoefficients (TauCoefficients);
        
    end

    
end