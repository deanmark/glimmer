classdef MoleculeData < handle
        
    properties (SetAccess = private)
        
        MoleculeName;
        MolecularLevels;
        
        %rows represent upper level, col's are lower level
        m_photonFrequencies;        
        %rows represent upper level, col's are lower level
        m_einsteinCoefficients;
        
        m_hConstant;
        
    end
    
    methods(Access = public)
        
        function MD = MoleculeData(MoleculeName,PhotonFrequencies,EinsteinCoefficients)

            MD.MoleculeName = MoleculeName;
            MD.MolecularLevels = max(PhotonFrequencies(:,1));
            MD.m_hConstant = Constants.h;
            
            MD.m_photonFrequencies = MD.buildPhotonFrequenciesArr (PhotonFrequencies);
            MD.m_einsteinCoefficients = EinsteinCoefficients;
            
        end
        
        function Frequency = TransitionFrequency (obj, HighLevel, LowLevel)

            if  LowLevel > HighLevel
                ME = MException('VerifyInput:levelMismatch','Error in input. HighLevel [%d] should be larger than LowLevel [%d]', HighLevel, LowLevel);
                throw(ME);
            end
            
            Frequency = obj.m_photonFrequencies(HighLevel, LowLevel);
            
        end
  
        function Energy = TransitionEnergy (obj, HighLevel, LowLevel)
            
            if  LowLevel > HighLevel
                ME = MException('VerifyInput:levelMismatch','Error in input. HighLevel [%d] should be larger than LowLevel [%d]', HighLevel, LowLevel);
                throw(ME);
            end
            
            Energy = obj.m_hConstant*obj.m_photonFrequencies(HighLevel, LowLevel);
                                        
        end
                
        function Einstein = EinsteinACoefficient(obj, HighLevel, LowLevel)
            if  LowLevel >= HighLevel
                ME = MException('VerifyInput:levelMismatch','Error in input. HighLevel [%d] should be larger than LowLevel [%d]', HighLevel, LowLevel);
                throw(ME);
                
            elseif HighLevel ~= LowLevel + 1
                ME = MException('VerifyInput:levelMismatch','Error in input. Level jumps larger than one are not supported. HighLevel [%d]. LowLevel [%d]', HighLevel, LowLevel);
                throw(ME);
            else
                index = find (obj.m_einsteinCoefficients(:,1)==HighLevel);
                
                if numel(index) == 0
                    ME = MException('VerifyInput:levelNotFound','Error in input. HighLevel [%d] not found in MoleculeData', HighLevel);
                    throw(ME);
                else
                    Einstein = obj.m_einsteinCoefficients(index(1), 3);
                end
            end
            
        end
        
        function SW = StatisticalWeight(obj, Level)
           
            SW = 2*(Level-1) + 1;
            
        end
        
    end
    
    methods(Access = private)
        
        function FullPhotonFrequencies = buildPhotonFrequenciesArr (obj, PhotonFrequencies)
            
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