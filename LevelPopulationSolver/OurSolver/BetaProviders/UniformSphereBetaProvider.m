classdef UniformSphereBetaProvider < LVGBetaProvider
   
    methods(Access=public)
        
        function BetaProvider = UniformSphereBetaProvider(MoleculeData, IgnoreNegativeTau, IncludeBackgroundRadiation, BackgroundTemperature)
            
            BetaProvider@LVGBetaProvider(MoleculeData, IgnoreNegativeTau, IncludeBackgroundRadiation, BackgroundTemperature);
            
        end
                
    end
    
    methods(Access=public)
        
        function BetaCoefficients = TauCoefficientsToBetaCoefficients (obj, TauCoefficients)
            
            smallNumbersLogicalIndex = (-10^-5 < TauCoefficients) & (TauCoefficients < 10^-5);
            
            BetaCoefficients = zeros(size(TauCoefficients));
            %use taylor expansion for small numbers. because matlab doesn't
            %handle small numbers well
            BetaCoefficients(smallNumbersLogicalIndex) = 1-(3/8)*TauCoefficients(smallNumbersLogicalIndex);
            
            x = TauCoefficients(~smallNumbersLogicalIndex);
            BetaCoefficients(~smallNumbersLogicalIndex) = (1.5./x).*(1 - (2./x.^2) + exp(-x).*( (2./x) +  (2./x.^2) ) );
                        
        end
        
    end
    
end