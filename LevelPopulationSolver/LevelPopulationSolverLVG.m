classdef LevelPopulationSolverLVG < LevelPopulationSolverOpticallyThin
    
    properties(SetAccess = protected)

        m_algorithmParameters;
        
    end
    
    properties(SetAccess = private)
        
        m_betaProvider;

        m_collisionRateMatrix;
        m_betaCoefficients;
        m_collisionPartnerDensities;
        
    end
    
    methods(Access=public)
        
        function LVG = LevelPopulationSolverLVG(MoleculeData, BetaProvider, LVGAlgorithmParameters)
            
            LVG@LevelPopulationSolverOpticallyThin(MoleculeData);
            LVG.m_betaProvider = BetaProvider;
            LVG.m_algorithmParameters = LVGAlgorithmParameters;
            
        end
        
        function Result = SolveLevelsPopulation(obj, PopulationRequest)
            
            Result = LVGSolverPopulationResult();
            numDensities = numel(PopulationRequest.CollisionPartnerDensities);
            
            obj.m_collisionRateMatrix = 0;
            obj.m_collisionPartnerDensities = PopulationRequest.CollisionPartnerDensities;
            obj.m_betaCoefficients = ones(PopulationRequest.NumLevelsForSolution, numDensities);
            
            if (isempty(PopulationRequest.FirstPopulationGuess))
                populationGuess = SolveLevelsPopulation@LevelPopulationSolverOpticallyThin(obj, PopulationRequest);
            else               
                populationGuess = PopulationRequest.FirstPopulationGuess;
            end
            
            i = 0;
            
            Result.MaxDiffPercentHistory = zeros (numDensities, obj.m_algorithmParameters.MaxIterations);
            Result.PopulationHistory = zeros (PopulationRequest.NumLevelsForSolution, numDensities, obj.m_algorithmParameters.MaxIterations);
            Result.TauHistory = zeros (PopulationRequest.NumLevelsForSolution, numDensities, obj.m_algorithmParameters.MaxIterations);
            Result.BetaHistory = zeros (PopulationRequest.NumLevelsForSolution, numDensities, obj.m_algorithmParameters.MaxIterations);
            requestOnlyNonConverged = PopulationRequest.Copy();
            
            converged = zeros (1, numDensities);
            haywired = zeros (1, numDensities);
            notFinished = ~(converged | haywired);
            
            while ( (i <= obj.m_algorithmParameters.MinIterations || i < obj.m_algorithmParameters.MaxIterations) && any(notFinished) )
                
                i = i + 1;
                
                % This feature isn't used. In principle this allows us to
                % guess the next population based on the new population and
                % old ones. We prefer to guess the next iteration based on
                % the beta coefficients.           
                populationGuess = obj.interpolateNextPopulation(populationGuess, Result.PopulationHistory, i);                               
                % Calculate beta coefficients from new population
                [obj.m_betaCoefficients, tau] = obj.m_betaProvider.CalculateBetaCoefficients(populationGuess, PopulationRequest.MoleculeDensity, PopulationRequest.VelocityDerivative);                
                % Interpolate our next beta guess based upon the beta
                % coefficients just found and old beta coefficients.
                obj.m_betaCoefficients = obj.interpolateNextBeta(obj.m_betaCoefficients, Result.BetaHistory, i);        
                % save population for the record
                Result.PopulationHistory(:,:,i) = populationGuess;                
                % Calculate the new population based on the beta
                % coefficients found and physical parameters. Calculate 
                % only for unconverged densities               
                requestOnlyNonConverged.CollisionPartnerDensities = PopulationRequest.CollisionPartnerDensities(notFinished);
                populationGuess(:,notFinished) = SolveLevelsPopulation@LevelPopulationSolverOpticallyThin(obj, requestOnlyNonConverged);
                 
                % debug indicators
                Result.MaxDiffPercentHistory(:,i) = 100*obj.calculateMeanDifferenceRatio(Result.PopulationHistory(:,:,i),populationGuess,true);
                Result.TauHistory(:,:,i) = tau;
                Result.BetaHistory(:,:,i) = obj.m_betaCoefficients;
                %

                % check for end of run
                haywired = obj.hasPopulationGoneHaywire(populationGuess);
                converged = obj.hasPopulationConverged(Result.PopulationHistory(:,:,i), populationGuess);
                notFinished = ~(converged | haywired);
                %
                
            end
            
            Result.MaxDiffPercentHistory = Result.MaxDiffPercentHistory(:,1:i);
            Result.TauHistory = Result.TauHistory(:,:,1:i);
            Result.BetaHistory = Result.BetaHistory(:,:,1:i);            
            Result.PopulationHistory = Result.PopulationHistory(:,:,1:i);
            
            Result.FinalTauCoefficients = tau;
            Result.FinalBetaCoefficients = obj.m_betaCoefficients;
            Result.Population = populationGuess;
            Result.Converged = converged & ~ haywired;
            Result.Iterations = i;
            
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
        function MeanDifferenceRatio = calculateMeanDifferenceRatio (obj, Pop1, Pop2, SignificantOnly)
            
            if (nargin == 4 && SignificantOnly)
                sgnfLvlsIndex = Pop2 > obj.m_algorithmParameters.SignificantPopulationThreshold;
            else
                sgnfLvlsIndex = ones(numel(Pop1),1);
            end
            
            diffRatio = abs(Pop1-Pop2)./Pop1;
            diffRatio(~sgnfLvlsIndex) = 0;
            
            MeanDifferenceRatio = sum(diffRatio,1)./sum(sgnfLvlsIndex,1);
            
        end
        
        function EinsteinMatrix = getEinsteinMatrix (obj, CollisionPartnerDensity)
            
            levels = size(obj.m_betaCoefficients,1);           
            
            densityIndex = obj.m_collisionPartnerDensities == CollisionPartnerDensity;
            EinsteinMatrix = obj.m_einsteinMatrix(1:levels,1:levels)*diag(obj.m_betaCoefficients(:,logical(densityIndex)));
            
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
            
            GoneHaywire = any(isnan(populationGuess));
            
        end
                
        function Converged = hasPopulationConverged (obj, OldPopulation, NewPopulation)
            %check for convergence
            
            %OldPopulation == 0 only on the first iteration
            if (numel(OldPopulation) ~= 1)
                
                %we want to check for convergence on significant levels.
                maxDiffRatio = obj.calculateMeanDifferenceRatio (OldPopulation, NewPopulation, true);
                
                Converged = maxDiffRatio < obj.m_algorithmParameters.ConvergenceThreshold;
                
            else
                Converged = zeros(1,numel(OldPopulation));
            end
        end
        
    end
    
end