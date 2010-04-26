classdef CosmicBackgroundProvider < handle
    
    properties (SetAccess = private)
        
        m_backgroundVector;
        m_backgroundConstants;
        
    end
    
    methods(Access=public)
        
        function Cosmic = CosmicBackgroundProvider(MoleculeData, BackgroundTemperature)
            
            Cosmic.initializeBackgroundVector(MoleculeData, BackgroundTemperature);
            
        end
        
        function ModifiedBeta = AddBackgroundRadiation(obj, Population, Beta)
            
            popRatios = zeros(size(Population));
            popRatios(2:end,:) = Population(1:(end-1),:)./Population(2:end,:);
            
            ModifiedBeta = repmat(obj.m_backgroundConstants,1,size(Population,2)) + repmat(obj.m_backgroundVector,1,size(Population,2)).*popRatios;
            ModifiedBeta = Beta.*ModifiedBeta;
            
        end
        
    end
    
    methods(Access=private)
       
        function initializeBackgroundVector (obj, MoleculeData, BackgroundTemperature)
            
            exponents = zeros(MoleculeData.MolecularLevels,1);
            statisticalWeightRatios = zeros(MoleculeData.MolecularLevels,1);
            
            for i=2:MoleculeData.MolecularLevels
                
                exponents(i) = exp(MoleculeData.TransitionEnergy(i, i-1)/(Constants.k*BackgroundTemperature));
                statisticalWeightRatios(i) = MoleculeData.StatisticalWeight(i)/MoleculeData.StatisticalWeight(i-1);
                
            end

            obj.m_backgroundConstants = 1+1./(exponents-1);
            obj.m_backgroundVector = - statisticalWeightRatios./(exponents-1);
            
        end
        
    end
    
end