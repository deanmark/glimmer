classdef LevelPopulationSolverLVG < LevelPopulationSolverOpticallyThin
    
    properties(SetAccess = private, Constant = true)
        
        m_minIterations = 4;
        m_convergenceThreshold = 10^-5; %relative difference
        m_significantPopulationThreshold = 0.001;
        
    end
    
    properties(SetAccess = private)
        
        m_maxIterations;        
        m_betaProvider;

        m_collisionRateMatrix;
        m_betaCoefficients;
        m_collisionPartnerDensities;
        
    end
    
    methods(Access=public)
        
        function LVG = LevelPopulationSolverLVG(MoleculeData, BetaProvider, MaxIterations)
            
            LVG@LevelPopulationSolverOpticallyThin(MoleculeData);
            
            if (nargin <3); MaxIterations = 1000; end
            LVG.m_maxIterations = MaxIterations;
                       
            LVG.m_betaProvider = BetaProvider;
            
        end
        
        function [Population, FinalBetaCoefficients, HasConverged, Iterations, MaxDiffPercentHistory, PopulationHistory, TauHistory, BetaHistory] = SolveLevelsPopulation(obj, CollisionPartnerRates, Weights, Temperature, CollisionPartnerDensities, VelocityDerivative, MoleculeDensity, NumLevelsForSolution)
            
            if (nargin < 8); NumLevelsForSolution=obj.m_moleculeData.MolecularLevels; end;
            
            numDensities = numel(CollisionPartnerDensities);
            
            obj.m_collisionRateMatrix = 0;
            obj.m_collisionPartnerDensities = CollisionPartnerDensities;
            obj.m_betaCoefficients = ones(obj.m_moleculeData.MolecularLevels, numDensities);
            
            populationGuess = SolveLevelsPopulation@LevelPopulationSolverOpticallyThin(obj, CollisionPartnerRates, Weights, Temperature, CollisionPartnerDensities, NumLevelsForSolution);
            
            i = 1;
            
            MaxDiffPercentHistory = zeros (numDensities, obj.m_maxIterations);
            PopulationHistory = zeros (obj.m_moleculeData.MolecularLevels, numDensities, obj.m_maxIterations);
            TauHistory = zeros (obj.m_moleculeData.MolecularLevels, numDensities, obj.m_maxIterations);
            BetaHistory = zeros (obj.m_moleculeData.MolecularLevels, numDensities, obj.m_maxIterations);
            
            converged = zeros (1, numDensities);
            haywired = zeros (1, numDensities);
            notFinished = ~(converged | haywired);
            
            while ( i <= obj.m_minIterations || (i < obj.m_maxIterations && any(notFinished)) )
                
                populationGuess = obj.interpolateNextPopulation(populationGuess, PopulationHistory, i);
                               
                [obj.m_betaCoefficients, tau] = obj.m_betaProvider.CalculateBetaCoefficients(populationGuess, MoleculeDensity, VelocityDerivative);
                
                obj.m_betaCoefficients = obj.interpolateNextBeta(obj.m_betaCoefficients, BetaHistory, i);
                
                PopulationHistory(:,:,i) = populationGuess;
                lastPopulationGuess = populationGuess;
                
                populationGuess(:,notFinished) = SolveLevelsPopulation@LevelPopulationSolverOpticallyThin(obj, CollisionPartnerRates, Weights, Temperature, CollisionPartnerDensities(notFinished), NumLevelsForSolution);
                %ignore negative population
                populationGuess(populationGuess < 0) = lastPopulationGuess(populationGuess < 0);
                 
                % debug indicators
                MaxDiffPercentHistory(:,i) = 100*obj.calculateMeanDifferenceRatio(PopulationHistory(:,:,i),populationGuess,true);
                TauHistory(:,:,i) = tau;
                BetaHistory(:,:,i) = obj.m_betaCoefficients;
                %

                haywired = obj.hasPopulationGoneHaywire(populationGuess);
                converged = obj.hasPopulationConverged(PopulationHistory(:,:,i), populationGuess);
                notFinished = ~(converged | haywired);
                
                i = i + 1;
                
            end
            
            FinalBetaCoefficients = obj.m_betaCoefficients;
            Population = populationGuess;
            HasConverged = converged & ~ haywired;
            Iterations = i;
            
        end
        
    end
    
    methods(Access=protected)
        
        %this function tries to find patterns in the population history, in
        %order to optimally guess the next population.
        function PopulationGuess = interpolateNextPopulation (obj, CurrentPopulationGuess, PopulationHistory, CurrentIteration)
        
            PopulationGuess = CurrentPopulationGuess;
            
        end
        
        %this function tries to find patterns in the beta history, in
        %order to optimally guess the next beta.
        function BetaGuess = interpolateNextBeta (obj, CurrentBetaGuess, BetaHistory, CurrentIteration)
           
            BetaGuess = CurrentBetaGuess;
            
        end

    end
    
    methods(Access=protected, Sealed=true)

        %mean (Pop1-Pop2)/Pop1
        function MaxDifferenceRatio = calculateMeanDifferenceRatio (obj, Pop1, Pop2, SignificantOnly)
            
            if (nargin == 4 && SignificantOnly)
                sgnfLvlsIndex = Pop2 > obj.m_significantPopulationThreshold;
            else
                sgnfLvlsIndex = ones(numel(Pop1),1);
            end
            
            diffRatio = abs(Pop1-Pop2)./Pop1;
            diffRatio(sgnfLvlsIndex) = 0;
            
            MaxDifferenceRatio = sum(diffRatio,1)./sum(sgnfLvlsIndex,1);
            
        end
        
        function EinsteinMatrix = getEinsteinMatrix (obj, CollisionPartnerDensity)
            
            densityIndex = obj.m_collisionPartnerDensities == CollisionPartnerDensity;
            EinsteinMatrix = obj.m_einsteinMatrix*diag(obj.m_betaCoefficients(:,logical(densityIndex)));
            
        end
        
        function CollisionRateMatrix = createCollisionRateMatrix (obj, CollisionPartnerRates, Weights, Temperature)
            
            if (obj.m_collisionRateMatrix==0)
                obj.m_collisionRateMatrix = createCollisionRateMatrix@LevelPopulationSolverOpticallyThin(obj, CollisionPartnerRates, Weights, Temperature);
            end
            
            CollisionRateMatrix = obj.m_collisionRateMatrix;
            
        end
                
    end
        
    methods(Access=private)
        
        function GoneHaywire = hasPopulationGoneHaywire(obj, populationGuess)
            
            nanSums = sum(isnan(populationGuess), 1);
            
            GoneHaywire = nanSums == size(populationGuess,1);
            
        end
                
        function Converged = hasPopulationConverged (obj, OldPopulation, NewPopulation)
            %check for convergence
            
            %OldPopulation == 0 only on the first iteration
            if (numel(OldPopulation) ~= 1)
                
                %we want to check for convergence on significant levels.
                maxDiffRatio = obj.calculateMeanDifferenceRatio (OldPopulation, NewPopulation, true);
                
                Converged = maxDiffRatio < obj.m_convergenceThreshold;
                
            else
                Converged = zeros(1,numel(OldPopulation));
            end
        end
        
    end
    
end