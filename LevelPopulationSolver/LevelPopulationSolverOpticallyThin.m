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
        function Population = SolveLevelsPopulation(obj, CollisionPartnerRates, Weights, Temperature, CollisionPartnerDensities, NumLevelsForSolution)
            
            if (nargin < 6)
                NumLevelsForSolution = obj.m_moleculeData.MolecularLevels;
            end            
            
            matrix = obj.createEquationMatrix(CollisionPartnerRates, Weights, Temperature, CollisionPartnerDensities);            
            Population = zeros(obj.m_moleculeData.MolecularLevels,numel(CollisionPartnerDensities));
            
            %take only the levels requested for solution
            subMatrix = matrix(1:NumLevelsForSolution,1:NumLevelsForSolution,:);
            
            sol = zeros(NumLevelsForSolution,1);
            sol(1,1) = 1;
                        
            for i=1:numel(CollisionPartnerDensities)           
                Population(1:NumLevelsForSolution,i) = subMatrix(:,:,i)\sol;
            end
            
        end
        
    end
    
    methods(Access=private)

        function EqMatrix = createEquationMatrix(obj, CollisionPartnerRates, Weights, Temperature, CollisionPartnerDensities)
            
            moleculerLevels = obj.m_moleculeData.MolecularLevels;
            
            EqMatrix = zeros(moleculerLevels,moleculerLevels,numel(CollisionPartnerDensities));
            collisionRateMatrix = obj.createCollisionRateMatrix(CollisionPartnerRates, Weights, Temperature);
            
            for i = 1:numel(CollisionPartnerDensities)
                
                EqMatrix(:,:,i) = obj.getEinsteinMatrix(CollisionPartnerDensities(i));
                
                EqMatrix(:,:,i) = EqMatrix(:,:,i) + CollisionPartnerDensities(i)*collisionRateMatrix;
                
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
                
                diagMembers = - collisionRateMatrix * ones (size(collisionRateMatrix,1),1);
                CollisionRateMatrix = CollisionRateMatrix + diag(diagMembers) + collisionRateMatrix';
                
            end
            
        end
        
        function EinsteinMatrix = getEinsteinMatrix (obj, CollisionPartnerDensity)
            EinsteinMatrix = obj.m_einsteinMatrix;
        end
        
        function EinsteinMatrix = createEinsteinMatrix (obj)
            
            moleculerLevels = obj.m_moleculeData.MolecularLevels;
            
            EinsteinMatrix = zeros(moleculerLevels,moleculerLevels);
            
            for eq=1:moleculerLevels
                %First add the Einstein coefficients
                if eq ~= 1
                    EinsteinMatrix(eq,eq) = - obj.m_moleculeData.EinsteinACoefficient(eq, eq-1);
                end
                
                if eq ~= moleculerLevels
                    EinsteinMatrix(eq,eq+1) = obj.m_moleculeData.EinsteinACoefficient(eq+1, eq);
                end
                
            end
            
        end
        
    end    
    
end