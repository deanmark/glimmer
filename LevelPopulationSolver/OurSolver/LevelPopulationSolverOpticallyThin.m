classdef LevelPopulationSolverOpticallyThin < handle
    
    properties(SetAccess = private)
        
        m_moleculeData;        
        m_einsteinMatrix;
        
    end
    
    methods(Access=public)
        
        function OThin = LevelPopulationSolverOpticallyThin(MoleculeData)
            
            OThin.m_moleculeData = MoleculeData;
          
            OThin.m_einsteinMatrix = OThin.createEinsteinMatrix();
            
        end

        %solves levels population. 
        %CollisionPartnerDensities is an array of densities for which a
        %solution is requested
        function Population = SolveLevelsPopulation(obj, PopulationRequest)
            
            matrix = obj.createEquationMatrix(PopulationRequest.CollisionPartners, PopulationRequest.Weights, PopulationRequest.Temperature, ...
                PopulationRequest.CollisionPartnerDensities, PopulationRequest.NumLevelsForSolution);            
            
            Population = zeros(PopulationRequest.NumLevelsForSolution,numel(PopulationRequest.CollisionPartnerDensities));
            
            %take only the levels requested for solution
            subMatrix = matrix(1:PopulationRequest.NumLevelsForSolution,1:PopulationRequest.NumLevelsForSolution,:);
            
            sol = zeros(PopulationRequest.NumLevelsForSolution,1);
            sol(1,1) = 1;
                        
            for i=1:numel(PopulationRequest.CollisionPartnerDensities)           
                Population(1:PopulationRequest.NumLevelsForSolution,i) = subMatrix(:,:,i)\sol;
            end
            
        end
        
    end
    
    methods(Access=private)

        function EqMatrix = createEquationMatrix(obj, CollisionPartnerRates, Weights, Temperature, CollisionPartnerDensities, NumLevelsForSolution)
            
            EqMatrix = zeros(NumLevelsForSolution,NumLevelsForSolution,numel(CollisionPartnerDensities));
            collisionRateMatrix = obj.createCollisionRateMatrix(CollisionPartnerRates, Weights, Temperature);
            
            for i = 1:numel(CollisionPartnerDensities)
                
                EqMatrix(:,:,i) = obj.getEinsteinMatrix(i);
                
                EqMatrix(:,:,i) = EqMatrix(:,:,i) + CollisionPartnerDensities(i)*collisionRateMatrix(1:NumLevelsForSolution,1:NumLevelsForSolution);
                
                %the last equation states that all coefficients should sum up to unity.
                EqMatrix(1,1:end, i) = 1;
            end
            
        end
       
    end
        
    methods(Access=protected)
        
        function CollisionRateMatrix = createCollisionRateMatrix (obj, CollisionPartnerRates, Weights, Temperature)
            
            totalWeights = sum(Weights);
            moleculerLevels = obj.m_moleculeData.MolecularLevels;
            
            CollisionRateMatrix = zeros(moleculerLevels,moleculerLevels);
            
            for i = 1: numel(CollisionPartnerRates)
                
                collisionRateMatrix = CollisionPartnerRates(i).CollisionRateMatrix(Temperature, Weights(i)/totalWeights);
                collisionRateMatrix = transpose(collisionRateMatrix);
                diagMembers = sum(collisionRateMatrix,1);
                
                CollisionRateMatrix = CollisionRateMatrix - diag(diagMembers) + collisionRateMatrix;
                
            end
            
        end
        
        function EinsteinMatrix = getEinsteinMatrix (obj, CollisionPartnerDensityIndex)
            EinsteinMatrix = obj.m_einsteinMatrix;
        end
        
        function EinsteinMatrix = createEinsteinMatrix (obj)
            
            moleculerLevels = obj.m_moleculeData.MolecularLevels;
            
            EinsteinMatrix = zeros(moleculerLevels,moleculerLevels);
            
            partialEinsteinMatrix = obj.m_moleculeData.EinsteinACoefficientMatrix();
            partialEinsteinMatrix = transpose(partialEinsteinMatrix);
            diagMembers = sum(partialEinsteinMatrix,1);
            
            EinsteinMatrix = EinsteinMatrix + partialEinsteinMatrix - diag(diagMembers);
            
        end
        
    end    
    
end