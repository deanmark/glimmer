classdef HomogeneousSlabBetaProvider < OpticalDepthProvider
    
    properties (SetAccess = private)
        
        m_ignoreNegativeTau;
        m_includeBackgroundRadiation;

        m_cosmicBackgroundProvider;
        
    end
    
    methods(Access=public)
        
        function HSlabBeta = HomogeneousSlabBetaProvider(MoleculeData, IgnoreNegativeTau, IncludeBackgroundRadiation, BackgroundTemperature)
            
            HSlabBeta@OpticalDepthProvider(MoleculeData);
            
            HSlabBeta.m_ignoreNegativeTau = IgnoreNegativeTau;
            HSlabBeta.m_includeBackgroundRadiation = IncludeBackgroundRadiation;
            
            if (IncludeBackgroundRadiation)
                HSlabBeta.m_cosmicBackgroundProvider = CosmicBackgroundProvider(MoleculeData, BackgroundTemperature);
            end
            
        end
        
        function [BetaCoefficients, TauCoefficients] = CalculateBetaCoefficients (obj, Population, MoleculeDensity, VelocityDerivative)
            
            TauCoefficients = obj.CalculateTauCoefficients(Population, MoleculeDensity, VelocityDerivative);
            
            if (obj.m_ignoreNegativeTau)
                TauCoefficients(TauCoefficients < 0) = 0;
            end
            
            smallNumbersLogicalIndex = (-10^-5 < TauCoefficients) & (TauCoefficients < 10^-5);
            
            BetaCoefficients = zeros(size(TauCoefficients));
            %use taylor expansion for small numbers. because matlab doesn't
            %handle small numbers well
            BetaCoefficients(smallNumbersLogicalIndex) = 1-1.5*TauCoefficients(smallNumbersLogicalIndex);
            
            BetaCoefficients(~smallNumbersLogicalIndex) = (1-exp(-3*TauCoefficients(~smallNumbersLogicalIndex)))./(3*TauCoefficients(~smallNumbersLogicalIndex));
            
            if (obj.m_includeBackgroundRadiation)
                BetaCoefficients = obj.m_cosmicBackgroundProvider.AddBackgroundRadiation(Population, BetaCoefficients);                
            end
                        
            BetaCoefficients(1) = 0;
            
        end
        
    end
    
end