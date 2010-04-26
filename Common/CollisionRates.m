classdef CollisionRates < handle
    
    properties (SetAccess = private)
        Molecule; % type MoleculeData
        CollisionPartnerCode; % type integer

        m_collisionRates;      
        m_temperatures;
        
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
            CR.m_temperatures = CollisionRates(1,3:end);
                        
            CR.m_collisionRates = CR.buildCollisionRatesArr(CollisionRates);
            
        end
        
        
        function C = CollisionRate(obj, LeftLevel, RightLevel, Temperature, CollisionPartnerDensity)
            
            C = CollisionPartnerDensity*obj.CollisionRateCoefficient(LeftLevel, RightLevel, Temperature);
            
        end
        
        function Q = CollisionRateCoefficient(obj, LeftLevel, RightLevel, Temperature)
                        
            %if temperature is larger or smaller than all the
            %temperatures, we do not interpolation, but use the value that is
            %closest to him
            
            if Temperature <= min(obj.m_temperatures)  
                temperatureCol = 1;
            elseif Temperature >= max(obj.m_temperatures)
                temperatureCol = numel(obj.m_temperatures);
            else                          
                temperatureCol = find (obj.m_temperatures==Temperature);
            end
            
            if ~isempty(temperatureCol) 
                %we have an exact match
                Q = obj.m_collisionRates(LeftLevel, RightLevel, temperatureCol);
            else
                %we need to interpolate. that is done with a simple linear
                %interpolation.
                
                lowTempIndex = find(obj.m_temperatures < Temperature, 1, 'last' );
                                
                lowTempQ = obj.m_collisionRates(LeftLevel, RightLevel, lowTempIndex);
                highTempQ = obj.m_collisionRates(LeftLevel, RightLevel, lowTempIndex+1);
                
                lowTemp = obj.m_temperatures(lowTempIndex);
                highTemp = obj.m_temperatures(lowTempIndex+1);
                                
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
            
            if Temperature <= min(obj.m_temperatures)  
                temperatureCol = 1;
            elseif Temperature >= max(obj.m_temperatures)
                temperatureCol = numel(obj.m_temperatures);
            else                          
                temperatureCol = find (obj.m_temperatures==Temperature);
            end
            
            if ~isempty(temperatureCol) 
                %we have an exact match
                Q = obj.m_collisionRates(:, :, temperatureCol);
            else
                %we need to interpolate. that is done with a simple linear
                %interpolation.
                
                lowTempIndex = find(obj.m_temperatures < Temperature, 1, 'last' );
                                
                lowTempQ = obj.m_collisionRates(:,:,lowTempIndex);
                highTempQ = obj.m_collisionRates(:,:,lowTempIndex+1);
                
                lowTemp = obj.m_temperatures(lowTempIndex);
                highTemp = obj.m_temperatures(lowTempIndex+1);
                                
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
            
            numTemperatures = numel(obj.m_temperatures);
            lvls = obj.Molecule.MolecularLevels;
            
            Rates = zeros (lvls,lvls, numTemperatures);
            
            %temperature loop
            for i=1:numTemperatures
            
                for j=2:size(CollRates,1);
                
                    highLvl = CollRates(j,1);
                    lowLvl = CollRates(j,2);
                    
                    %from high to low is as given in the table
                    Rates(highLvl,lowLvl, i) = CollRates(j,i+2);
                    
                    %from low to high we need to use the principle of
                    %detailed balance
                    Rates(lowLvl,highLvl, i) = obj.computeReverseCollisionRate(highLvl, lowLvl, CollRates(j,i+2), obj.m_temperatures(i));
                    
                end
                    
            end
            
        end
        
        %computes the reverse collision rate with the principle of detailed balance
        function QLowToHigh = computeReverseCollisionRate(obj, HighLvl, LowLvl, QHighToLow, Temperature)
            
            gHigh = obj.Molecule.StatisticalWeight(HighLvl);
            gLow = obj.Molecule.StatisticalWeight(LowLvl);
            energy = obj.Molecule.TransitionEnergy(HighLvl,LowLvl);
            
            QLowToHigh = (gHigh/gLow)*QHighToLow*exp(-1*energy/(Constants.k*Temperature));
            
        end
        
    end
    
end