classdef UniformSphereBetaProvider < OpticalDepthProvider
    
    properties (SetAccess = public)
        
        IgnoreNegativeTau;
        IncludeBackgroundRadiation;
        
    end
    
    properties (SetAccess = private)
        
        m_cosmicBackgroundProvider;
        
    end
    
    methods(Access=public)
        
        function USphereBeta = UniformSphereBetaProvider(MoleculeData, IgnoreNegativeTau, IncludeBackgroundRadiation, BackgroundTemperature)
            
            USphereBeta@OpticalDepthProvider(MoleculeData);
            
            USphereBeta.IgnoreNegativeTau = IgnoreNegativeTau;
            USphereBeta.IncludeBackgroundRadiation = IncludeBackgroundRadiation;
            
            if (IncludeBackgroundRadiation)
                USphereBeta.m_cosmicBackgroundProvider = CosmicBackgroundProvider(MoleculeData, BackgroundTemperature);
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
            BetaCoefficients(smallNumbersLogicalIndex) = 1-(3/8)*TauCoefficients(smallNumbersLogicalIndex);
            
            x = TauCoefficients(~smallNumbersLogicalIndex);
            BetaCoefficients(~smallNumbersLogicalIndex) = (1.5./x).*(1 - (2./x.^2) + exp(-x).*( (2./x) +  (2./x.^2) ) );
            
            if (obj.IncludeBackgroundRadiation)               
                BetaCoefficients = obj.m_cosmicBackgroundProvider.AddBackgroundRadiation(Population, BetaCoefficients);                
            end
                        
            BetaCoefficients(1) = 0;
            
        end
        
    end
    
end