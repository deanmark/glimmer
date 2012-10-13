%{
GLIMMER is a visual LVG (Large Velocity Gradient) analysis tool.

Copyright (C) 2012  Dean Mark <deanmark at gmail>, 
		Prof. Amiel Sternberg <amiel at wise.tau.ac.il>, 
		Department of Astrophysics, Tel-Aviv University

Documentation for the program is posted at http://deanmark.github.com/glimmer/

This file is part of GLIMMER.

GLIMMER is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

GLIMMER is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
%}

classdef MoleculeData < handle
    % Holds all data relevant to a molecule.
    
    properties (SetAccess = private)
        
        % Molecule name.
        MoleculeName;
        % Number of molecular levels.
        MolecularLevels; 
        % File name containing the molecule data.
        MoleculeFileName; 
        
        % [MolecularLevels,MolecularLevels] Array of photon transition frequencies [Hz]. 
        % Rows represent upper level. Columns represent lower level
        % Cells contain transition frequency [Hz] from upper level to lower level.
        m_photonFrequencies; 
        % [MolecularLevels,MolecularLevels] Array of Einstein A Coefficients [1/sec]. 
        % Rows represent upper level. Columns represent lower level
        % Cells contain Einstein A Coefficients [1/sec].
        m_einsteinACoefficients; 
        % [MolecularLevels,MolecularLevels] Array of Einstein B Coefficients [1/sec]. 
        % Rows represent upper level. Columns represent lower level
        % Cells contain Einstein B Coefficients [1/sec].
        m_einsteinBCoefficients; 
        
        % Load h constant locally. This improves performance.
        m_hConstant; 
        
        % Contains the collision partner rates of the molecule.
        m_collisionPartners;
        % Contains an array of the statistical weights, one for each level.
        m_statisticalWeights;
        
    end
    
    methods(Access = public)
         
        function MD = MoleculeData(MoleculeName,PhotonFrequencies,EinsteinACoefficients,MoleculeFileName,StatisticalWeights)
            % Constructor
            % Input:
            %    MoleculeName = Molecule name.
            %    PhotonFrequencies = [Levels,3] array
            %       First column contains upper level index. 
            %       Second column contains lower level index. 
            %       Third column contains transition frequency [Hz] from
            %       upper level to lower level.
            %    EinsteinCoefficients = [Levels,3] array
            %       First column contains upper level index. 
            %       Second column contains lower level index. 
            %       Third column contains Einstein A Coefficients.
            %    MoleculeFileName = Molecule file name.
            
            MD.MoleculeName = MoleculeName;
            MD.MolecularLevels = numel(StatisticalWeights);
            MD.m_hConstant = Constants.h;
            MD.MoleculeFileName = MoleculeFileName;
                        
            MD.m_statisticalWeights = StatisticalWeights;
            MD.m_photonFrequencies = MD.buildPhotonFrequenciesArr (PhotonFrequencies);
            MD.m_collisionPartners = Hashtable();

            MD.m_einsteinACoefficients = MD.buildEinsteinACoefficientsTable(EinsteinACoefficients);
            MD.m_einsteinBCoefficients = MD.buildEinsteinBCoefficientsTable(EinsteinACoefficients);
            
        end
        
        function Frequency = TransitionFrequency (obj, HighLevel, LowLevel)
            % Returns the photon transition frequency from HighLevel to LowLevel
            % Input:
            %    HighLevel = Count one level
            %    LowLevel = Count one level
            % Output:
            %    Frequency = Photon transition frequency [Hz]
            
            if  any(LowLevel > HighLevel)
                ME = MException('VerifyInput:levelMismatch','Error in input. HighLevel [%d] should be larger than LowLevel [%d]', HighLevel, LowLevel);
                throw(ME);
            end
                        
            ind = sub2ind(size(obj.m_photonFrequencies),HighLevel,LowLevel);
            Frequency = obj.m_photonFrequencies(ind);
            
        end
  
        function Energy = TransitionEnergy (obj, HighLevel, LowLevel)
            % Returns the transition energy from HighLevel to LowLevel
            % Input:
            %    HighLevel = Count one level
            %    LowLevel = Count one level
            % Output:
            %    Frequency = Photon transition energy [erg]
            
            if  any(LowLevel > HighLevel)
                ME = MException('VerifyInput:levelMismatch','Error in input. HighLevel [%d] should be larger than LowLevel [%d]', HighLevel, LowLevel);
                throw(ME);
            end
            
            ind = sub2ind(size(obj.m_photonFrequencies),HighLevel,LowLevel);
            Energy = obj.m_hConstant*obj.m_photonFrequencies(ind);
                                        
        end
                
        function Einstein = EinsteinACoefficient(obj, HighLevel, LowLevel)
            % Returns the Einstein A Coefficient from HighLevel to LowLevel
            % Input:
            %    HighLevel = Count one level
            %    LowLevel = Count one level
            % Output:
            %    Einstein = Transition Einstein A Coefficient [1/sec]
            
            if  any(LowLevel >= HighLevel)
                ind = find(LowLevel >= HighLevel);
                ME = MException('VerifyInput:levelMismatch','Error in input. HighLevel [%d] should be larger than LowLevel [%d]', HighLevel(ind(1)), LowLevel(ind(1)));
                throw(ME);
            end
            
            ind = sub2ind(size(obj.m_einsteinACoefficients),HighLevel,LowLevel);
            Einstein = obj.m_einsteinACoefficients(ind);
            
        end
        
        function Einstein = EinsteinACoefficientMatrix(obj)
            Einstein = obj.m_einsteinACoefficients;
        end

        function Einstein = EinsteinBCoefficientMatrix(obj)
            Einstein = obj.m_einsteinBCoefficients;
        end
        
        function SW = StatisticalWeight(obj, Level)
            % Returns the statistical weight of the Level.
            % Input:
            %    Level = Count one level
            % Output:
            %    SW = The statistical weight
            
            SW = obj.m_statisticalWeights(Level);
            
        end
        
        function AddCollisionPartners (obj, CollisionPartners)
           
            for i=1:numel(CollisionPartners)               
                obj.m_collisionPartners.Put(num2str(CollisionPartners{i}.CollisionPartnerCode),CollisionPartners{i});
            end
            
        end
        
        function CollPartnerCodes = CollisionPartnerCodes(obj)
            CollPartnerCodes = str2double(obj.m_collisionPartners.Keys());
        end
        
        function CollPartnerNames = CollisionPartnerNames(obj)
            partners = obj.m_collisionPartners.Values();
            
            names = {};
            
            for i=1:numel(partners)
                names = [names, CollisionPartnersCodes.ToString(partners{i}.CollisionPartnerCode)];
            end
            
            CollPartnerNames = names;
        end
        
        function CollisionPartner = GetCollisionPartner(obj, CollisionPartnerCode)
            CollisionPartner = obj.m_collisionPartners.Get(num2str(CollisionPartnerCode));
        end
        
    end
    
    methods(Access = private)
        
        function FullPhotonFrequencies = buildPhotonFrequenciesArr (obj, PhotonFrequencies)
            % Builds the full transition array from 1 step transition freq's.
            % Input:
            %    PhotonFrequencies = [MolecularLevels,3] array. 
            %       First column contains upper level index. 
            %       Second column contains lower level index. 
            %       Third column contains transition frequency [Hz] from
            %       upper level to lower level.
            % Output:
            %    FullPhotonFrequencies = [MolecularLevels,MolecularLevels] Array containing all transition frequencies.
            %       Rows represent upper level. Columns represent lower level
            %       Cells contain transition frequency [Hz] from upper level to lower level.
            
            lvls = obj.MolecularLevels;
            FullPhotonFrequencies = zeros(lvls,lvls);
            
            highLevels = PhotonFrequencies(:,1);
            lowLevels = PhotonFrequencies(:,2);
            freq = PhotonFrequencies(:,3);
            
            ind = sub2ind(size(FullPhotonFrequencies),highLevels,lowLevels);
            FullPhotonFrequencies(ind) = freq;
            sequentalTransitions = diag(FullPhotonFrequencies,-1);
            
            for i=3:lvls
                for j = 1:i-2               
                    
                    FullPhotonFrequencies(i,j) = sum(sequentalTransitions(j:i-1));
                    
                end
            end
               
        end
        
        function EinsteinTable = buildEinsteinACoefficientsTable(obj, EinsteinACoefficients)
            % Builds the full einstein A coefficients table.
            % Input:
            %    EinsteinACoefficients = [Transitions,3] array. 
            %       First column contains upper level index. 
            %       Second column contains lower level index. 
            %       Third column contains einstein A coefficient from
            %       upper level to lower level.
            % Output:
            %    EinsteinTable = [MolecularLevels,MolecularLevels] Array containing all einstein A coefficients.
            %       Rows represent upper level. Columns represent lower level
            %       Cells contain einstein A coefficients from upper
            %       level to lower level.
        
            lvls = obj.MolecularLevels;
            
            EinsteinTable = zeros(lvls,lvls);
            
            highLevels = EinsteinACoefficients(:,1);
            lowLevels = EinsteinACoefficients(:,2);
            rates = EinsteinACoefficients(:,3);
            
            ind = sub2ind(size(EinsteinTable),highLevels,lowLevels);
            EinsteinTable(ind) = rates;
            
        end
        
        function EinsteinTable = buildEinsteinBCoefficientsTable(obj, EinsteinACoefficients)
            % Builds the full einstein B coefficients table.
            % Input:
            %    EinsteinACoefficients = [Transitions,3] array. 
            %       First column contains upper level index. 
            %       Second column contains lower level index. 
            %       Third column contains einstein B coefficient from
            %       upper level to lower level.
            % Output:
            %    EinsteinTable = [MolecularLevels,MolecularLevels] Array containing all einstein B coefficients.
            %       Rows represent upper level. Columns represent lower level
            %       Cells contain einstein B coefficients from upper
            %       level to lower level.
        
            lvls = obj.MolecularLevels;
            
            EinsteinTable = zeros(lvls,lvls);
            
            highLevels = EinsteinACoefficients(:,1);
            lowLevels = EinsteinACoefficients(:,2);
            aRates = EinsteinACoefficients(:,3);
            freq = obj.TransitionFrequency(highLevels,lowLevels);
            bRates = (Constants.c^2 ./ (2*Constants.h .* freq.^3)) .* aRates;
            
            statWghtsUpper = obj.StatisticalWeight(highLevels);
            statWghtsLower = obj.StatisticalWeight(lowLevels);
            
            bRatesReverse = (statWghtsUpper ./ statWghtsLower) .* bRates;            
            
            ind = sub2ind(size(EinsteinTable),highLevels,lowLevels);
            EinsteinTable(ind) = bRates;
            
            ind = sub2ind(size(EinsteinTable),lowLevels,highLevels);
            EinsteinTable(ind) = bRatesReverse;            
            
        end
        
    end
    
end
