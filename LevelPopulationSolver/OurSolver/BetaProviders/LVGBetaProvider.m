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
    
        
    methods (Access=public, Abstract)

        [BetaCoefficients, TauCoefficients] = CalculateBetaCoefficients (obj, Population, MoleculeDensity, VelocityDerivative);
    
    end
    
end