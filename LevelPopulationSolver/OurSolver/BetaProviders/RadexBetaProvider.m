classdef RadexBetaProvider < OpticalDepthProvider
    
    properties (SetAccess = public)
        
        IgnoreNegativeTau;
        IncludeBackgroundRadiation;
        
    end
    
    properties (SetAccess = private)
        
        m_cosmicBackgroundProvider;
        
    end
    
    methods(Access=public)
        
        function LVGBeta = RadexBetaProvider(MoleculeData, IgnoreNegativeTau, IncludeBackgroundRadiation, BackgroundTemperature)
            
            LVGBeta@OpticalDepthProvider(MoleculeData);
            
            LVGBeta.IgnoreNegativeTau = IgnoreNegativeTau;
            LVGBeta.IncludeBackgroundRadiation = IncludeBackgroundRadiation;
            
            if (IncludeBackgroundRadiation)
                LVGBeta.m_cosmicBackgroundProvider = CosmicBackgroundProvider(MoleculeData, BackgroundTemperature);
            end
            
        end
        
        function [BetaCoefficients, TauCoefficients] = CalculateBetaCoefficients (obj, Population, MoleculeDensity, VelocityDerivative)
            
%             RADEX CODE:
%             if (abs(taur).lt.0.01) then
%                 beta = 1.0
%             elseif(abs(taur).lt.7.0) then
%                     beta = 2.0*(1.0 - dexp(-2.34*taur))/(4.68*taur)
%             else
%                 beta = 2.0/(taur*4.0*(sqrt(log(taur/sqrt(pi)))))
%             end
            
            TauCoefficients = obj.CalculateTauCoefficients(Population, MoleculeDensity, VelocityDerivative);
            
            if (obj.IgnoreNegativeTau)
                TauCoefficients(TauCoefficients < 0) = 0;
            end
            
            smallNumbersLogicalIndex = abs(TauCoefficients) < 0.01;
            mediumNumbersLogicalIndex = 0.01 <= abs(TauCoefficients) & abs(TauCoefficients) < 7;
            largeNumbersLogicalIndex = ~smallNumbersLogicalIndex & ~mediumNumbersLogicalIndex;
            
            BetaCoefficients = zeros(size(TauCoefficients));
            %use taylor expansion for small numbers. because matlab doesn't
            %handle small numbers well
            BetaCoefficients(smallNumbersLogicalIndex) = 1;
            BetaCoefficients(mediumNumbersLogicalIndex) = 2*(1-exp(-2.34*TauCoefficients(mediumNumbersLogicalIndex)))./(4.68*TauCoefficients(mediumNumbersLogicalIndex));
            BetaCoefficients(largeNumbersLogicalIndex) = 2./(TauCoefficients(largeNumbersLogicalIndex)*4.*sqrt(log(TauCoefficients(largeNumbersLogicalIndex)./sqrt(Constants.pi))));
            
            if (obj.IncludeBackgroundRadiation)               
                BetaCoefficients = obj.m_cosmicBackgroundProvider.AddBackgroundRadiation(Population, BetaCoefficients);                
            end
                        
            BetaCoefficients(1) = 0;
            
        end
        
    end
    
end