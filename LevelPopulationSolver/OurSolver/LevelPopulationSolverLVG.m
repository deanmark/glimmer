classdef LevelPopulationSolverLVG < LevelPopulationSolverOpticallyThin
    
    properties(SetAccess = protected)

        m_algorithmParameters;
        
    end
    
    properties(SetAccess = private)
        
        m_betaProvider;

        m_collisionRateMatrix;
        m_betaCoefficients;
        m_collisionPartnerDensities;
        m_initialSolver;
        
    end
    
    methods(Access=public)
        
        function LVG = LevelPopulationSolverLVG(MoleculeData, BetaProvider, LVGAlgorithmParameters)
            
            LVG@LevelPopulationSolverOpticallyThin(MoleculeData);
            LVG.m_betaProvider = BetaProvider;
            LVG.m_algorithmParameters = LVGAlgorithmParameters;
            
            if BetaProvider.IncludeBackgroundRadiation
                LVG.m_initialSolver = LevelPopulationSolverOpticallyThinWithBackground(MoleculeData,BetaProvider.BackgroundTemperature);
            else
                LVG.m_initialSolver = LevelPopulationSolverOpticallyThin(MoleculeData);
            end
        end
        
        function Result = SolveLevelsPopulation(obj, PopulationRequest)
            
            numDensities = numel(PopulationRequest.CollisionPartnerDensities);
            
            obj.m_collisionRateMatrix = [];
            obj.m_collisionPartnerDensities = PopulationRequest.CollisionPartnerDensities;
            obj.m_betaCoefficients = ones(PopulationRequest.NumLevelsForSolution, numDensities);
            
            if (isempty(PopulationRequest.FirstPopulationGuess))
                populationGuess = obj.m_initialSolver.SolveLevelsPopulation(PopulationRequest);
            else
                populationGuess = PopulationRequest.FirstPopulationGuess;
            end
            
            i = 0;
            
            Result = LVGSolverPopulationResult();
            
            if PopulationRequest.DebugIndicators
                Result.MaxDiffPercentHistory = zeros (numDensities, obj.m_algorithmParameters.MaxIterations);
                Result.PopulationHistory = zeros (PopulationRequest.NumLevelsForSolution, numDensities, obj.m_algorithmParameters.MaxIterations);
                Result.TauHistory = zeros (PopulationRequest.NumLevelsForSolution, numDensities, obj.m_algorithmParameters.MaxIterations);
                Result.BetaHistory = zeros (PopulationRequest.NumLevelsForSolution, numDensities, obj.m_algorithmParameters.MaxIterations);
            end
            
            requestOnlyNonConverged = PopulationRequest.Copy();
            
            converged = zeros (1, numDensities);
            haywired = zeros (1, numDensities);
            notFinished = ~(converged | haywired);
            tau = zeros(PopulationRequest.NumLevelsForSolution,numDensities);
            lastBeta = zeros(PopulationRequest.NumLevelsForSolution,numDensities);
            
            while ( (i <= obj.m_algorithmParameters.MinIterations || i < obj.m_algorithmParameters.MaxIterations) && any(notFinished) )
                
                i = i + 1;
                
                % Calculate beta coefficients from new population
                [obj.m_betaCoefficients(:,notFinished), tau(:,notFinished)] = obj.m_betaProvider.CalculateBetaCoefficients(populationGuess(:,notFinished), ...
                    PopulationRequest.CollisionPartnerDensities(notFinished)*PopulationRequest.MoleculeAbundanceRatios, PopulationRequest.VelocityDerivative);
                % Interpolate our next beta guess based upon the beta
                % coefficients just found and old beta coefficients.
                obj.m_betaCoefficients(:,notFinished) = obj.interpolateNextBeta(obj.m_betaCoefficients(:,notFinished), lastBeta(:,notFinished), i);
                % save population for the record
                lastPopulation = populationGuess;
                % Calculate the new population based on the beta
                % coefficients found and physical parameters. Calculate
                % only for unconverged densities               
                requestOnlyNonConverged.CollisionPartnerDensities = PopulationRequest.CollisionPartnerDensities(notFinished);
                populationGuess(:,notFinished) = SolveLevelsPopulation@LevelPopulationSolverOpticallyThin(obj, requestOnlyNonConverged);
                 
                lastBeta = obj.m_betaCoefficients;
                % debug indicators
                if PopulationRequest.DebugIndicators
                    Result.MaxDiffPercentHistory(:,i) = 100*obj.calculateMeanDifferenceRatio(Result.PopulationHistory(:,:,i),populationGuess,true);
                    Result.TauHistory(:,:,i) = tau;
                    Result.BetaHistory(:,:,i) = obj.m_betaCoefficients;
                    Result.PopulationHistory(:,:,i) = lastPopulation;
                end

                % check for end of run
                haywired = obj.hasPopulationGoneHaywire(populationGuess);
                converged = obj.hasPopulationConverged(lastPopulation, populationGuess);
                notFinished = ~(converged | haywired);
                %
                
            end
            
            if PopulationRequest.DebugIndicators
                Result.MaxDiffPercentHistory = Result.MaxDiffPercentHistory(:,1:i);
                Result.TauHistory = Result.TauHistory(:,:,1:i);
                Result.BetaHistory = Result.BetaHistory(:,:,1:i);
                Result.PopulationHistory = Result.PopulationHistory(:,:,1:i);
            end
            
            [Result.FinalBetaCoefficients, Result.FinalTauCoefficients] = obj.m_betaProvider.CalculateBetaCoefficients(populationGuess, ...
                PopulationRequest.CollisionPartnerDensities*PopulationRequest.MoleculeAbundanceRatios, PopulationRequest.VelocityDerivative);
            Result.Population = populationGuess;
            Result.Converged = converged & ~ haywired;
            Result.Iterations = i;
            
        end
        
    end
    
    methods(Access=protected)
        
        %this function tries to find patterns in the beta history, in
        %order to optimally guess the next beta.
        function BetaGuess = interpolateNextBeta (obj, CurrentBetaGuess, LastBeta, CurrentIteration)
            
            if (CurrentIteration > 1)
                BetaGuess = LastBeta*(1-obj.m_algorithmParameters.ChangePercent) + CurrentBetaGuess*obj.m_algorithmParameters.ChangePercent;
            else
                BetaGuess = CurrentBetaGuess;
            end
            
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
            
            maxPop = max(Pop1, Pop2);            
            diffRatio = abs(Pop1-Pop2)./maxPop;
            diffRatio(~sgnfLvlsIndex) = 0;
            
            MeanDifferenceRatio = sum(diffRatio,1)./sum(sgnfLvlsIndex,1);
            
        end
        
        function EinsteinMatrix = getEinsteinMatrix (obj, CollisionPartnerDensityIndex)
            
            levels = size(obj.m_betaCoefficients,1);           
            
            EinsteinMatrix = obj.m_einsteinMatrix(1:levels,1:levels)*diag(obj.m_betaCoefficients(:,CollisionPartnerDensityIndex));
            
        end
        
        function CollisionRateMatrix = createCollisionRateMatrix (obj, CollisionPartnerRates, Weights, Temperature)
            
            if isempty(obj.m_collisionRateMatrix)
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