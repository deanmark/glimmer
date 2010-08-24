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
            MD.m_einsteinACoefficients = EinsteinACoefficients;
            MD.m_collisionPartners = Hashtable();
            
        end
        
        function Frequency = TransitionFrequency (obj, HighLevel, LowLevel)
            % Returns the photon transition frequency from HighLevel to LowLevel
            % Input:
            %    HighLevel = Count one level
            %    LowLevel = Count one level
            % Output:
            %    Frequency = Photon transition frequency [Hz]
            
            if  LowLevel > HighLevel
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
            
            if  LowLevel > HighLevel
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
            
            if  LowLevel >= HighLevel
                ME = MException('VerifyInput:levelMismatch','Error in input. HighLevel [%d] should be larger than LowLevel [%d]', HighLevel, LowLevel);
                throw(ME);
                
            elseif HighLevel ~= LowLevel + 1
                ME = MException('VerifyInput:levelMismatch','Error in input. Level jumps larger than one are not supported. HighLevel [%d]. LowLevel [%d]', HighLevel, LowLevel);
                throw(ME);
            else
                index = find (obj.m_einsteinACoefficients(:,1)==HighLevel);
                
                if numel(index) == 0
                    ME = MException('VerifyInput:levelNotFound','Error in input. HighLevel [%d] not found in MoleculeData', HighLevel);
                    throw(ME);
                else
                    Einstein = obj.m_einsteinACoefficients(index(1), 3);
                end
            end
            
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
            
            for i=1:lvls
                for j = 1:i
               
                    if i ~= j
                        levelTransitions = (j+1):i;
                        
                        indices = ismember(PhotonFrequencies(:,1),levelTransitions);
                        
                        frequencies = PhotonFrequencies(logical(indices), 3);
                        FullPhotonFrequencies(i,j) = sum(frequencies);
                    end
                    
                end
            end
               
        end
        
    end
    
end 