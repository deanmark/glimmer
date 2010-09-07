classdef PopulationSolverHelper
    
    methods (Access=public, Static=true)
        
        function FinalResult = CalculateLVGPopulation (PopulationRequest)
            
            PopulationSolverHelper.validateInput(PopulationRequest);
            [MoleculeData, BetaProvider, innerRequest ] = PopulationSolverHelper.changeRequestToInnerRequest (PopulationRequest);
            FinalResult = PopulationSolverHelper.initializeResult(PopulationRequest);
            
            LVGSolverLowExcitation = LevelPopulationSolverLVG(MoleculeData, BetaProvider, LVGSolverAlgorithmParameters.DefaultInitialRunParamsLowExcitation());
            LVGSolverHighExcitation = LevelPopulationSolverLVG(MoleculeData, BetaProvider, LVGSolverAlgorithmParameters.DefaultInitialRunParamsHighExcitation);
            LVGSolverAccurate = LevelPopulationSolverLVG(MoleculeData, BetaProvider, LVGSolverAlgorithmParameters.DefaultConfirmationRunParamsHighExcitation());
            
            if (PopulationRequest.CalculateIntensities)
                IntensitiesClc = IntensitiesCalculator(MoleculeData);
            end
            
            totalComputations = numel(PopulationRequest.VelocityDerivative)*numel(PopulationRequest.Temperature)*numel(PopulationRequest.CollisionPartnerDensities);
            i = 0;
            
            for dvDrIndex=1:numel(PopulationRequest.VelocityDerivative)
                
                for tempIndex=1:numel(PopulationRequest.Temperature)
                    
                    for densIndex=1:numel(PopulationRequest.CollisionPartnerDensities)
                        
                        PopulationSolverHelper.fillInnerRequest(innerRequest,PopulationRequest.Temperature(tempIndex),PopulationRequest.VelocityDerivative(dvDrIndex),...
                            PopulationRequest.CollisionPartnerDensities(densIndex),PopulationRequest.MoleculeDensity(densIndex),PopulationRequest.CloudColumnDensity(densIndex), PopulationRequest.FirstPopulationGuess)
                        BetaProvider.IgnoreNegativeTau = true;
                        
                        if innerRequest.CollisionPartnerDensities >= 10
                            innerRequest.FirstPopulationGuess = [];
                            NoNegativeTauResult = LVGSolverHighExcitation.SolveLevelsPopulation(innerRequest);
                            
                            if ~NoNegativeTauResult.Converged
                                display('arrgh!');
                            end
                            
                            BetaProvider.IgnoreNegativeTau = false;
                            innerRequest.FirstPopulationGuess = NoNegativeTauResult.Population;
                            Result = LVGSolverAccurate.SolveLevelsPopulation(innerRequest);
                        else
                            NoNegativeTauResult = LVGSolverLowExcitation.SolveLevelsPopulation(innerRequest);
                            
                            if NoNegativeTauResult.Converged
                                innerRequest.FirstPopulationGuess = NoNegativeTauResult.Population;
                            else
                                display('arrgh!');
                            end
                            
                            BetaProvider.IgnoreNegativeTau = false;
                            Result = LVGSolverAccurate.SolveLevelsPopulation(innerRequest);
                        end
                        
                        FinalResult.Converged(tempIndex,densIndex,dvDrIndex) = Result.Converged;
                        
                        if Result.Converged
                            
                            FinalResult.Population(:,tempIndex,densIndex,dvDrIndex) = Result.Population;
                            FinalResult.FinalBetaCoefficients(:,tempIndex,densIndex,dvDrIndex) = Result.FinalBetaCoefficients;
                            FinalResult.FinalTauCoefficients(:,tempIndex,densIndex,dvDrIndex) = Result.FinalTauCoefficients;
                            
                            if (PopulationRequest.CalculateIntensities)
                                
                                FinalResult.Intensities(:,tempIndex,densIndex,dvDrIndex) = IntensitiesClc.CalculateIntensitiesLVG(Result.Population, ...
                                    Result.FinalTauCoefficients, innerRequest.CloudColumnDensity);
                            end
                            
                        end
                        
                        i=i+1;
                        PopulationSolverHelper.showProgress(i, totalComputations);
                        
                    end
                end
                
            end
            
        end
        
        function FinalResult = CalculateLVGPopulationDensityParallel (PopulationRequest)
            
            PopulationSolverHelper.validateInput(PopulationRequest);
            [MoleculeData, BetaProvider, innerRequest ] = PopulationSolverHelper.changeRequestToInnerRequest (PopulationRequest);
            FinalResult = PopulationSolverHelper.initializeResult(PopulationRequest);
            
            LVGSolverLowExcitation = LevelPopulationSolverLVG(MoleculeData, BetaProvider, LVGSolverAlgorithmParameters.DefaultInitialRunParamsLowExcitation());
            LVGSolverHighExcitation = LevelPopulationSolverLVG(MoleculeData, BetaProvider, LVGSolverAlgorithmParameters.DefaultInitialRunParamsHighExcitation);
            LVGSolverAccurate = LevelPopulationSolverLVG(MoleculeData, BetaProvider, LVGSolverAlgorithmParameters.DefaultConfirmationRunParamsHighExcitation());
            
            if (PopulationRequest.CalculateIntensities)
                IntensitiesClc = IntensitiesCalculator(MoleculeData); 
            end
            
            totalComputations = numel(PopulationRequest.VelocityDerivative)*numel(PopulationRequest.Temperature);
            i = 0;
            
            for dvDrIndex=1:numel(PopulationRequest.VelocityDerivative)
                
                for tempIndex=1:numel(PopulationRequest.Temperature)
                    
                    PopulationSolverHelper.fillInnerRequest(innerRequest,PopulationRequest.Temperature(tempIndex),PopulationRequest.VelocityDerivative(dvDrIndex),...
                        PopulationRequest.CollisionPartnerDensities,PopulationRequest.MoleculeDensity,PopulationRequest.CloudColumnDensity, PopulationRequest.FirstPopulationGuess)
                    BetaProvider.IgnoreNegativeTau = true;
                    
                    if innerRequest.CollisionPartnerDensities >= 10
                        innerRequest.FirstPopulationGuess = [];
                        NoNegativeTauResult = LVGSolverHighExcitation.SolveLevelsPopulation(innerRequest);
                        
                        if ~NoNegativeTauResult.Converged
                            display('arrgh!');
                        end
                        
                        BetaProvider.IgnoreNegativeTau = false;
                        innerRequest.FirstPopulationGuess = NoNegativeTauResult.Population;
                        Result = LVGSolverAccurate.SolveLevelsPopulation(innerRequest);
                    else
                        NoNegativeTauResult = LVGSolverLowExcitation.SolveLevelsPopulation(innerRequest);
                        
                        if NoNegativeTauResult.Converged
                            innerRequest.FirstPopulationGuess = NoNegativeTauResult.Population;
                        else
                            display('arrgh!');
                        end
                        
                        BetaProvider.IgnoreNegativeTau = false;
                        Result = LVGSolverAccurate.SolveLevelsPopulation(innerRequest);
                    end
                    
                    FinalResult.Converged(tempIndex,:,dvDrIndex) = Result.Converged;
                                        
                    FinalResult.Population(:,tempIndex,:,dvDrIndex) = Result.Population;
                    FinalResult.FinalBetaCoefficients(:,tempIndex,:,dvDrIndex) = Result.FinalBetaCoefficients;
                    FinalResult.FinalTauCoefficients(:,tempIndex,:,dvDrIndex) = Result.FinalTauCoefficients;
                    
                    if (PopulationRequest.CalculateIntensities)                        
                        FinalResult.Intensities(:,tempIndex,:,dvDrIndex) = IntensitiesClc.CalculateIntensitiesLVG(Result.Population, ...
                            Result.FinalTauCoefficients, innerRequest.CloudColumnDensity);
                    end
                                        
                    i=i+1;
                    PopulationSolverHelper.showProgress(i, totalComputations);
                    
                end
                
            end
            
        end
         
        function FinalResult = CalculateOpticallyThinPopulation (PopulationRequest)
            
            PopulationSolverHelper.validateInput(PopulationRequest);
            [MoleculeData, BetaProvider, innerRequest ] = PopulationSolverHelper.changeRequestToInnerRequest (PopulationRequest);
            FinalResult = PopulationSolverHelper.initializeResult(PopulationRequest);
            
            OThin = LevelPopulationSolverOpticallyThin(MoleculeData);
            
            if (PopulationRequest.CalculateIntensities)
                IntensitiesClc = IntensitiesCalculator(MoleculeData); 
            end
            
            FinalResult.Converged = ones(size(FinalResult.Converged));
            FinalResult.FinalBetaCoefficients = ones(size(FinalResult.FinalBetaCoefficients));
            FinalResult.FinalTauCoefficients = zeros(size(FinalResult.FinalTauCoefficients));
            
            totalComputations = numel(PopulationRequest.VelocityDerivative)*numel(PopulationRequest.Temperature);
            i = 0;
            
            for dvDrIndex=1:numel(PopulationRequest.VelocityDerivative)
                
                for tempIndex=1:numel(PopulationRequest.Temperature)                    
                    
                    PopulationSolverHelper.fillInnerRequest(innerRequest,PopulationRequest.Temperature(tempIndex),PopulationRequest.VelocityDerivative(dvDrIndex),...
                        PopulationRequest.CollisionPartnerDensities,PopulationRequest.MoleculeDensity,PopulationRequest.CloudColumnDensity, PopulationRequest.FirstPopulationGuess)
                                        
                    Population = OThin.SolveLevelsPopulation(innerRequest);
                    
                    FinalResult.Population(:,tempIndex,:,dvDrIndex) = Population;
                    
                    if (PopulationRequest.CalculateIntensities)                        
                        FinalResult.Intensities(:,tempIndex,:,dvDrIndex) = IntensitiesClc.CalculateIntensitiesLVG(Population, ...
                            squeeze(FinalResult.FinalTauCoefficients(:,tempIndex,:,dvDrIndex)), innerRequest.CloudColumnDensity);
                    end
                    
                    i=i+1;
                    PopulationSolverHelper.showProgress(i, totalComputations);
                    
                end
                
            end
            
        end
        
        function FinalResult = CalculateLTEPopulation (PopulationRequest)
            
            PopulationSolverHelper.validateInput(PopulationRequest);
            [MoleculeData, BetaProvider, innerRequest ] = PopulationSolverHelper.changeRequestToInnerRequest (PopulationRequest);
            FinalResult = PopulationSolverHelper.initializeResult(PopulationRequest);
            
            LTESolver = LevelPopulationSolverLTE(MoleculeData);
            
            if (PopulationRequest.CalculateIntensities)
                IntensitiesClc = IntensitiesCalculator(MoleculeData);
            end
            
            FinalResult.Converged = ones(size(FinalResult.Converged));
            FinalResult.FinalBetaCoefficients = ones(size(FinalResult.FinalBetaCoefficients));
            FinalResult.FinalTauCoefficients = zeros(size(FinalResult.FinalTauCoefficients));
            
            totalComputations = numel(PopulationRequest.VelocityDerivative)*numel(PopulationRequest.Temperature);
            i = 0;
            
            for dvDrIndex=1:numel(PopulationRequest.VelocityDerivative)
                
                for tempIndex=1:numel(PopulationRequest.Temperature)
                    
                    PopulationSolverHelper.fillInnerRequest(innerRequest,PopulationRequest.Temperature(tempIndex),PopulationRequest.VelocityDerivative(dvDrIndex),...
                        PopulationRequest.CollisionPartnerDensities,PopulationRequest.MoleculeDensity,PopulationRequest.CloudColumnDensity, PopulationRequest.FirstPopulationGuess)
                                        
                    Population = LTESolver.SolveLevelsPopulation(innerRequest);
                    
                    FinalResult.Population(:,tempIndex,:,dvDrIndex) = Population;
                    
                    if (PopulationRequest.CalculateIntensities)                        
                        FinalResult.Intensities(:,tempIndex,:,dvDrIndex) = IntensitiesClc.CalculateIntensitiesLVG(Population, ...
                            squeeze(FinalResult.FinalTauCoefficients(:,tempIndex,:,dvDrIndex)), innerRequest.CloudColumnDensity);
                    end
                    
                    i=i+1;
                    PopulationSolverHelper.showProgress(i, totalComputations);
                    
                end
                
            end
            
        end
        
        function FinalResult = CalculateRadexLVGPopulation (PopulationRequest)
            
            PopulationSolverHelper.validateInput(PopulationRequest);
            [MoleculeData, BetaProvider, innerRequest ] = PopulationSolverHelper.changeRequestToInnerRequest (PopulationRequest);
            FinalResult = PopulationSolverHelper.initializeResult(PopulationRequest);
                        
            totalComputations = numel(PopulationRequest.VelocityDerivative)*numel(PopulationRequest.Temperature)*numel(PopulationRequest.CollisionPartnerDensities);
            i = 0;
            
            for dvDrIndex=1:numel(PopulationRequest.VelocityDerivative)                
                for tempIndex=1:numel(PopulationRequest.Temperature)                    
                    for densIndex=1:numel(PopulationRequest.CollisionPartnerDensities)
                        
                        innerRequest.Temperature = PopulationRequest.Temperature(tempIndex);
                        innerRequest.VelocityDerivative = PopulationRequest.VelocityDerivative(dvDrIndex);
                        innerRequest.CollisionPartnerDensities = PopulationRequest.CollisionPartnerDensities(densIndex);
                        innerRequest.MoleculeDensity = PopulationRequest.MoleculeDensity(densIndex);
                        
                        [ Result, Converged, RuntimeMessage ] = RadexSolver.CalculateLVGPopulation(innerRequest);
                        
                        FinalResult.Converged(tempIndex,densIndex,dvDrIndex) = Converged;
                        
                        if Converged
                            
                            FinalResult.Population(1:numel(Result.Population),tempIndex,densIndex,dvDrIndex) = Result.Population;
                            FinalResult.FinalTauCoefficients(2:end,tempIndex,densIndex,dvDrIndex) = Result.Tau(1:PopulationRequest.NumLevelsForSolution-1);
                            
                            FinalResult.Intensities(2:end,tempIndex,densIndex,dvDrIndex) = Result.Flux_erg_cm2_s(1:PopulationRequest.NumLevelsForSolution-1)/4/Constants.pi;
                            
                        end
                        
                        i=i+1;
                        PopulationSolverHelper.showProgress(i, totalComputations);                    
                        
                    end
                end
            end            
        end
        
        function FinalResult = ProcessPopulationRequest (PopulationRequest)
            
            switch PopulationRequest.RunTypeCode
                case RunTypeCodes.LVG
                    FinalResult = PopulationSolverHelper.CalculateLVGPopulationDensityParallel(PopulationRequest);
                    
                case RunTypeCodes.OpticallyThin
                    FinalResult = PopulationSolverHelper.CalculateOpticallyThinPopulation(PopulationRequest);
                    
                case RunTypeCodes.LTE
                    FinalResult = PopulationSolverHelper.CalculateLTEPopulation(PopulationRequest);
                    
                case RunTypeCodes.Radex
                    FinalResult = PopulationSolverHelper.CalculateRadexLVGPopulation(PopulationRequest);
                    
                otherwise
                    ME = MException('VerifyInput:UnknownRunTypeCode','Error in input. Run Type Code [%d] is unknown', PopulationRequest.RunTypeCode);
                    throw(ME);
            end
            
        end
        
    end
    
    methods (Access=private, Static=true)
        
        function fillInnerRequest(InnerRequest, Temperature, VelocityDerivative, CollisionPartnerDensities, MoleculeDensity, CloudColumnDensity, FirstPopulationGuess)
           
            InnerRequest.Temperature = Temperature;
            InnerRequest.VelocityDerivative = VelocityDerivative;
            InnerRequest.CollisionPartnerDensities = CollisionPartnerDensities;
            InnerRequest.MoleculeDensity = MoleculeDensity;
            InnerRequest.CloudColumnDensity = CloudColumnDensity;
            InnerRequest.FirstPopulationGuess = FirstPopulationGuess;
            
        end
        
        function validateInput(PopulationRequest)
            
            p = inputParser();
            p.addRequired('PopulationRequest', @(x)isa(x,'LVGSolverPopulationRequest'));
            p.parse(PopulationRequest);
            
        end        
        
        function FinalResult = initializeResult(PopulationRequest)
            
            FinalResult = LVGSolverPopulationResult();
            FinalResult.OriginalRequest = PopulationRequest;
            FinalResult.Population = zeros(PopulationRequest.NumLevelsForSolution, numel(PopulationRequest.Temperature), ...
                numel(PopulationRequest.CollisionPartnerDensities), numel(PopulationRequest.VelocityDerivative));
            FinalResult.FinalBetaCoefficients = zeros(size(FinalResult.Population));
            FinalResult.FinalTauCoefficients = zeros(size(FinalResult.Population));
            FinalResult.Intensities = zeros(size(FinalResult.Population));
            FinalResult.Converged = zeros(numel(PopulationRequest.Temperature), ...
                numel(PopulationRequest.CollisionPartnerDensities), numel(PopulationRequest.VelocityDerivative));
            
        end
        
        function [Molecule, BetaProvider, InnerRequest] = changeRequestToInnerRequest (PopulationRequest)
            
            Molecule = WorkspaceHelper.GetMoleculeDataFromWorkspace(PopulationRequest.MoleculeFileName);            
            BetaProvider = PopulationSolverHelper.createBetaProvider(PopulationRequest.BetaTypeCode, Molecule, PopulationRequest.BackgroundTemperature);
            
            InnerRequest = PopulationRequest.Copy();
            PopulationSolverHelper.replaceCollisionPartnerCodesToRates(InnerRequest,Molecule);            
            
        end
        
        function BetaProvider = createBetaProvider (BetaProviderCode, MoleculeData, BackgroundTemperature)
            
            switch BetaProviderCode
                case BetaTypeCodes.ExpandingSphere
                    BetaProvider = ExpandingSphereBetaProvider(MoleculeData, false, BackgroundTemperature~=0, BackgroundTemperature);
                case BetaTypeCodes.HomogeneousSlab
                    BetaProvider = HomogeneousSlabBetaProvider(MoleculeData, false, BackgroundTemperature~=0, BackgroundTemperature);
                case BetaTypeCodes.UniformSphere
                    BetaProvider = UniformSphereBetaProvider(MoleculeData, false, BackgroundTemperature~=0, BackgroundTemperature);                                        
                otherwise
                    ME = MException('VerifyInput:unknownBetaProviderCode','Error in input. Beta Provider code [%d] is unknown', BetaProviderCode);
                    throw(ME);
            end 
            
        end
        
        function replaceCollisionPartnerCodesToRates (PopulationRequest, MoleculeData)
            
            collisionPartnerCodes =  PopulationRequest.CollisionPartners;
            collisionPartnerRates = CollisionRates.empty(0,numel(collisionPartnerCodes));
            
            for i=1:numel(collisionPartnerCodes)
               
                collisionPartnerRates(i) = MoleculeData.GetCollisionPartner(collisionPartnerCodes(i));
               
            end
            
            PopulationRequest.CollisionPartners = collisionPartnerRates;
            
        end
        
        function showProgress(Iteration, TotalComputations)
            
            if TotalComputations > 1
                
                progress = Iteration/TotalComputations;
                
                if Iteration==1
                    fprintf(1, 'Progress: %%%3d', floor(100*progress));
                else
                    fprintf(1, '\b\b\b%3d', floor(100*progress));
                end
                
                if Iteration==TotalComputations
                    fprintf(1, '\n');
                end
            end
            
        end
        
    end
    
end