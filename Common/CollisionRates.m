classdef CollisionRates < handle
    
    properties (SetAccess = private)
        Molecule; % type MoleculeData
        CollisionPartnerCode; % type integer
        Temperatures;
        
        m_collisionRates;      
        
    end
    
    methods(Access = public)
        
        %CollisionRates has a certain structure that users should
        %abide to:
        %tab tab 100 200
        %2 1 1.2E-10 3.1E-20
        %on the first row appear the temperatures.
        %on the second row: first col is the initial level, second col is the final level.
        %in between appear the appropriate collision rates.  
        function CR = CollisionRates(MoleculeData,CollisionPartner,CollisionRates)
            
            CR.CollisionPartnerCode = CollisionPartner;
            CR.Molecule = MoleculeData;
            CR.Temperatures = CollisionRates(1,3:end);
                        
            CR.m_collisionRates = CR.buildCollisionRatesArr(CollisionRates);
            
        end
        
        
        function C = CollisionRate(obj, LeftLevel, RightLevel, Temperature, CollisionPartnerDensity)
            
            C = CollisionPartnerDensity*obj.CollisionRateCoefficient(LeftLevel, RightLevel, Temperature);
            
        end
        
        function Q = CollisionRateCoefficient(obj, LeftLevel, RightLevel, Temperature)
                        
            %if temperature is larger or smaller than all the
            %temperatures, we do not interpolate, but use the value that is
            %closest to him
            
            if Temperature <= min(obj.Temperatures)  
                temperatureCol = 1;
            elseif Temperature >= max(obj.Temperatures)
                temperatureCol = numel(obj.Temperatures);
            else                          
                temperatureCol = find (obj.Temperatures==Temperature);
            end
            
            if ~isempty(temperatureCol) 
                %we have an exact match
                Q = obj.m_collisionRates(LeftLevel, RightLevel, temperatureCol);
            else
                %we need to interpolate. that is done with a simple linear
                %interpolation.
                
                lowTempIndex = find(obj.Temperatures < Temperature, 1, 'last' );
                                
                lowTempQ = obj.m_collisionRates(LeftLevel, RightLevel, lowTempIndex);
                highTempQ = obj.m_collisionRates(LeftLevel, RightLevel, lowTempIndex+1);
                
                lowTemp = obj.Temperatures(lowTempIndex);
                highTemp = obj.Temperatures(lowTempIndex+1);
                                
                ratio = (Temperature - lowTemp)/(highTemp-lowTemp);
                  
                Q = (highTempQ - lowTempQ)*ratio + lowTempQ;
                
            end
            
        end
        
        
        function C = CollisionRateMatrix(obj, Temperature, CollisionPartnerDensity)
            
            C = CollisionPartnerDensity*obj.CollisionRateCoefficientMatrix(Temperature);
            
        end
        
        function Q = CollisionRateCoefficientMatrix(obj, Temperature)
                        
            %if Temperature is larger or smaller than all the
            %temperatures, we do not interpolate, but use the temperature that is
            %closest to him as an approximation
            
            if Temperature <= min(obj.Temperatures)  
                temperatureCol = 1;
            elseif Temperature >= max(obj.Temperatures)
                temperatureCol = numel(obj.Temperatures);
            else                          
                temperatureCol = find (obj.Temperatures==Temperature);
            end
            
            if ~isempty(temperatureCol) 
                %we have an exact match
                Q = obj.m_collisionRates(:, :, temperatureCol);
            else
                %we need to interpolate. that is done with a simple linear
                %interpolation.
                
                lowTempIndex = find(obj.Temperatures < Temperature, 1, 'last' );
                                
                lowTempQ = obj.m_collisionRates(:,:,lowTempIndex);
                highTempQ = obj.m_collisionRates(:,:,lowTempIndex+1);
                
                lowTemp = obj.Temperatures(lowTempIndex);
                highTemp = obj.Temperatures(lowTempIndex+1);
                                
                ratio = (Temperature - lowTemp)/(highTemp-lowTemp);
                  
                Q = (highTempQ - lowTempQ)*ratio + lowTempQ;
                
            end
            
        end        
        
    end
    
    methods(Access = private)
        
        %creates an array of collision rates. a table is created for each
        %temperature, such that each row represents the right index, and
        %each column represents the left index.
        function Rates = buildCollisionRatesArr (obj, CollRates)
            
            numTemperatures = numel(obj.Temperatures);
            lvls = obj.Molecule.MolecularLevels;
            
            Rates = zeros (lvls,lvls, numTemperatures);           
            
            highLevelsColumn = CollRates(2:end,1);
            lowLevelsColumn = CollRates(2:end,2);
            
            goodValues = highLevelsColumn > lowLevelsColumn;
            
            highLevels = highLevelsColumn(goodValues);
            lowLevels = lowLevelsColumn(goodValues);            
            
            statisticalWeightsHigh = obj.Molecule.StatisticalWeight(highLevels);
            statisticalWeightsLow = obj.Molecule.StatisticalWeight(lowLevels);            
            transitionEnergies = obj.Molecule.TransitionEnergy(highLevels,lowLevels);
            
            %temperature loop
            for i=1:numTemperatures
            
                RatesPerTemperature = zeros (lvls,lvls);
                
                QHighToLow = CollRates(2:end,i+2);  
                %computes the reverse collision rate with the principle of detailed balance
                QLowToHigh = (statisticalWeightsHigh./statisticalWeightsLow).*QHighToLow(goodValues).*exp(-1*transitionEnergies/(Constants.k*obj.Temperatures(i)));
                
                ind = sub2ind(size(RatesPerTemperature),lowLevels,highLevels);
                RatesPerTemperature(ind) = QLowToHigh;
                
                ind = sub2ind(size(RatesPerTemperature),highLevels,lowLevels);
                RatesPerTemperature(ind) = QHighToLow(goodValues);
                
                %directly input explicit reverse rates.
                ind = sub2ind(size(RatesPerTemperature),highLevelsColumn(~goodValues),lowLevelsColumn(~goodValues));
                RatesPerTemperature(ind) = QHighToLow(~goodValues);
                                
                Rates(:,:,i) = RatesPerTemperature;
                    
            end
            
        end
        
        
        function QLowToHigh = computeReverseCollisionRate(obj, HighLvl, LowLvl, QHighToLow, Temperature)
            
            gHigh = obj.Molecule.StatisticalWeight(HighLvl);
            gLow = obj.Molecule.StatisticalWeight(LowLvl);
            energy = obj.Molecule.TransitionEnergy(HighLvl,LowLvl);
            
            QLowToHigh = (gHigh/gLow)*QHighToLow*exp(-1*energy/(Constants.k*Temperature));
            
        end
        
    end
    
end