classdef LVGBetaProvider < OpticalDepthProvider
    
    properties (SetAccess = public)
        
        IgnoreNegativeTau;
        IncludeBackgroundRadiation;
        
    end
    
    properties (SetAccess = private)
        
        m_cosmicBackgroundProvider;
        
    end
    
    methods(Access=public)
        
        function LVGBeta = LVGBetaProvider(MoleculeData, IgnoreNegativeTau, IncludeBackgroundRadiation, BackgroundTemperature)
            
            LVGBeta@OpticalDepthProvider(MoleculeData);
            
            LVGBeta.IgnoreNegativeTau = IgnoreNegativeTau;
            LVGBeta.IncludeBackgroundRadiation = IncludeBackgroundRadiation;
            
            if (IncludeBackgroundRadiation)
                LVGBeta.m_cosmicBackgroundProvider = CosmicBackgroundProvider(MoleculeData, BackgroundTemperature);
            end
            
        end
        
        function [BetaCoefficients, TauCoefficients] = CalculateBetaCoefficients (obj, Population, MoleculeDensity, VelocityDerivative)
            
            TauCoefficients = obj.CalculateTauCoefficients(Population, MoleculeDensity, VelocityDerivative);
            
            if (obj.IgnoreNegativeTau)
                TauCoefficients(TauCoefficients < 0) = 0;
            end
            
            smallNumbersLogicalIndex = (-10^-5 < TauCoefficients) & (TauCoefficients < 10^-5);
            
            BetaCoefficients = zeros(size(TauCoefficients));
            %use taylor expansion for small numbers. because matlab doesn't
            %handle small numbers well
            BetaCoefficients(smallNumbersLogicalIndex) = 1-0.5*TauCoefficients(smallNumbersLogicalIndex);
            
            BetaCoefficients(~smallNumbersLogicalIndex) = (1-exp(-TauCoefficients(~smallNumbersLogicalIndex)))./TauCoefficients(~smallNumbersLogicalIndex);
            
            if (obj.IncludeBackgroundRadiation)               
                BetaCoefficients = obj.m_cosmicBackgroundProvider.AddBackgroundRadiation(Population, BetaCoefficients);                
            end
                        
            BetaCoefficients(1) = 0;
            
        end
        
    end
    
end