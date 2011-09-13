classdef HomogeneousSlabBetaProvider < LVGBetaProvider
    
    methods(Access=public)
        
        function BetaProvider = HomogeneousSlabBetaProvider(MoleculeData, IgnoreNegativeTau, IncludeBackgroundRadiation, BackgroundTemperature)
            
            BetaProvider@LVGBetaProvider(MoleculeData, IgnoreNegativeTau, IncludeBackgroundRadiation, BackgroundTemperature);
            
        end
        
    end
    
    methods(Access=public)
        
        function BetaCoefficients = TauCoefficientsToBetaCoefficients (obj, TauCoefficients)
            
            smallNumbersLogicalIndex = (-10^-5 < TauCoefficients) & (TauCoefficients < 10^-5);
            
            BetaCoefficients = zeros(size(TauCoefficients));
            %use taylor expansion for small numbers. because matlab doesn't
            %handle small numbers well
            BetaCoefficients(smallNumbersLogicalIndex) = 1-1.5*TauCoefficients(smallNumbersLogicalIndex);
            
            x = TauCoefficients(~smallNumbersLogicalIndex);
            BetaCoefficients(~smallNumbersLogicalIndex) = (1-exp(-3*x))./(3*x);
                        
        end
        
    end
    
end