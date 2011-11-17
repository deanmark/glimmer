classdef PopulationSolverHelper < handle
    
    properties
        
        ProgressFraction = 0;
        StopOperation = false;
        
    end
    
    methods (Access=public)
        
        function FinalResult = CalculateLVGPopulation (obj, OuterPopulationRequest)
            
            [MoleculeData, BetaProvider, innerRequest, FinalResult] = obj.initialize (OuterPopulationRequest);
            PopulationRequest = FinalResult.OriginalRequest;
            
            LVGSolverLowExcitation = LevelPopulationSolverLVG(MoleculeData, BetaProvider, LVGSolverAlgorithmParameters.DefaultInitialRunParamsLowExcitation());
            LVGSolverHighExcitation = LevelPopulationSolverLVG(MoleculeData, BetaProvider, LVGSolverAlgorithmParameters.DefaultInitialRunParamsHighExcitation);
            LVGSolverAccurate = LevelPopulationSolverLVG(MoleculeData, BetaProvider, LVGSolverAlgorithmParameters.DefaultConfirmationRunParamsHighExcitation());
            
            IntensitiesClc = IntensitiesCalculator(MoleculeData, OuterPopulationRequest.BackgroundTemperature~=0, OuterPopulationRequest.BackgroundTemperature);
            
            totalComputations = numel(PopulationRequest.VelocityDerivative)*numel(PopulationRequest.Temperature)*numel(PopulationRequest.CollisionPartnerDensities)*...
                numel(PopulationRequest.MoleculeAbundanceRatios)*numel(PopulationRequest.ConstantNpartnerBydVdR);
            i = 0;
            
            for dvDrIndex=1:numel(PopulationRequest.VelocityDerivative)
                for tempIndex=1:numel(PopulationRequest.Temperature)
                    for molAbundanceIndex=1:numel(PopulationRequest.MoleculeAbundanceRatios)
                        for collPartnerDensityIndex=1:numel(PopulationRequest.CollisionPartnerDensities)
                            for constantNpartnerBydVdRIndex=1:numel(PopulationRequest.ConstantNpartnerBydVdR)
                                
                                %each request runs individually
                                PopulationSolverHelper.fillInnerRequest(innerRequest,PopulationRequest.Temperature(tempIndex),PopulationRequest.VelocityDerivative(dvDrIndex),PopulationRequest.VelocityDerivativeUnits,...
                                    PopulationRequest.CollisionPartnerDensities(collPartnerDensityIndex),PopulationRequest.MoleculeAbundanceRatios(molAbundanceIndex), ...
                                    PopulationRequest.ConstantNpartnerBydVdR(constantNpartnerBydVdRIndex), PopulationRequest.FirstPopulationGuess);
                                
                                BetaProvider.IgnoreNegativeTau = true;
                                
                                if innerRequest.CollisionPartnerDensities >= 10
                                    NoNegativeTauResult = LVGSolverHighExcitation.SolveLevelsPopulation(innerRequest);
                                    
                                    BetaProvider.IgnoreNegativeTau = false;
                                    innerRequest.FirstPopulationGuess = NoNegativeTauResult.Population;
                                    Result = LVGSolverAccurate.SolveLevelsPopulation(innerRequest);
                                else
                                    NoNegativeTauResult = LVGSolverLowExcitation.SolveLevelsPopulation(innerRequest);
                                    
                                    if NoNegativeTauResult.Converged
                                        innerRequest.FirstPopulationGuess = NoNegativeTauResult.Population;
                                    end
                                    
                                    BetaProvider.IgnoreNegativeTau = false;
                                    Result = LVGSolverAccurate.SolveLevelsPopulation(innerRequest);
                                end
                                
                                FinalResult.Converged(tempIndex,collPartnerDensityIndex,dvDrIndex,molAbundanceIndex,constantNpartnerBydVdRIndex) = Result.Converged;
                                
                                if Result.Converged
                                    
                                    FinalResult.Population(:,tempIndex,collPartnerDensityIndex,dvDrIndex,molAbundanceIndex,constantNpartnerBydVdRIndex) = Result.Population;
                                    FinalResult.FinalBetaCoefficients(:,tempIndex,collPartnerDensityIndex,dvDrIndex,molAbundanceIndex,constantNpartnerBydVdRIndex) = Result.FinalBetaCoefficients;
                                    FinalResult.FinalTauCoefficients(:,tempIndex,collPartnerDensityIndex,dvDrIndex,molAbundanceIndex,constantNpartnerBydVdRIndex) = Result.FinalTauCoefficients;
                                                                            
                                    FinalResult.Intensities(:,tempIndex,collPartnerDensityIndex,dvDrIndex,molAbundanceIndex,constantNpartnerBydVdRIndex) = IntensitiesClc.CalculateIntensitiesLVG(Result.Population, ...
                                        Result.FinalTauCoefficients, PopulationRequest.MoleculeAbundanceRatios(molAbundanceIndex));
                                    FinalResult.ExcitationTemperature(:,tempIndex,collPartnerDensityIndex,dvDrIndex,molAbundanceIndex,constantNpartnerBydVdRIndex) = ...
                                        IntensitiesClc.CalculateExcitationTemperature(Result.Population);
                                    
                                end
                                
                                i=i+1;
                                
                                obj.showProgress(i, totalComputations);
                                obj.checkForStopFlag();
                                
                            end
                        end
                    end
                end
                
            end
            
        end
             
        function FinalResult = CalculateNonLVGPopulation(obj, OuterPopulationRequest)
            
            [MoleculeData, BetaProvider, innerRequest, FinalResult] = obj.initialize (OuterPopulationRequest);
            PopulationRequest = FinalResult.OriginalRequest;
            
            switch PopulationRequest.RunTypeCode
                case RunTypeCodes.OpticallyThin
                    solver = LevelPopulationSolverOpticallyThin(MoleculeData);
                case RunTypeCodes.LTE
                    solver = LevelPopulationSolverLTE(MoleculeData);
                case RunTypeCodes.OpticallyThinWithBackground
                    solver = LevelPopulationSolverOpticallyThinWithBackground(MoleculeData, PopulationRequest.BackgroundTemperature);
            end
                       
            IntensitiesClc = IntensitiesCalculator(MoleculeData, OuterPopulationRequest.BackgroundTemperature~=0, OuterPopulationRequest.BackgroundTemperature);
                        
            FinalResult.Converged = ones(size(FinalResult.Converged));
            FinalResult.FinalBetaCoefficients = ones(size(FinalResult.FinalBetaCoefficients));
            FinalResult.FinalTauCoefficients = zeros(size(FinalResult.FinalTauCoefficients));
            
            totalComputations = numel(PopulationRequest.VelocityDerivative)*numel(PopulationRequest.Temperature)*...
                numel(PopulationRequest.MoleculeAbundanceRatios)*numel(PopulationRequest.ConstantNpartnerBydVdR);
            i = 0;
            
            for dvDrIndex=1:numel(PopulationRequest.VelocityDerivative)
                for tempIndex=1:numel(PopulationRequest.Temperature)
                    for molAbundanceIndex=1:numel(PopulationRequest.MoleculeAbundanceRatios)
                        for constantNpartnerBydVdRIndex=1:numel(PopulationRequest.ConstantNpartnerBydVdR)
                            
                            PopulationSolverHelper.fillInnerRequest(innerRequest,PopulationRequest.Temperature(tempIndex),PopulationRequest.VelocityDerivative(dvDrIndex),PopulationRequest.VelocityDerivativeUnits,...
                                PopulationRequest.CollisionPartnerDensities,PopulationRequest.MoleculeAbundanceRatios(molAbundanceIndex),...
                                PopulationRequest.ConstantNpartnerBydVdR(constantNpartnerBydVdRIndex), PopulationRequest.FirstPopulationGuess);
                            
                            Population = solver.SolveLevelsPopulation(innerRequest);
                            
                            FinalResult.Population(:,tempIndex,:,dvDrIndex,molAbundanceIndex,constantNpartnerBydVdRIndex) = Population;
                            
                            if PopulationRequest.RunTypeCode == RunTypeCodes.LTE
                                FinalResult.Intensities(:,tempIndex,:,dvDrIndex,molAbundanceIndex,constantNpartnerBydVdRIndex) = repmat(IntensitiesClc.CalculateFluxLTE(PopulationRequest.Temperature(tempIndex),...
                                    PopulationRequest.MoleculeAbundanceRatios(molAbundanceIndex)),1,numel(PopulationRequest.CollisionPartnerDensities));
                            else
                                FinalResult.Intensities(:,tempIndex,:,dvDrIndex,molAbundanceIndex,constantNpartnerBydVdRIndex) = IntensitiesClc.CalculateIntensitiesLVG(Population, ...
                                    squeeze(FinalResult.FinalTauCoefficients(:,tempIndex,:,dvDrIndex,molAbundanceIndex,constantNpartnerBydVdRIndex)),PopulationRequest.MoleculeAbundanceRatios(molAbundanceIndex));
                            end
                            
                            i=i+1;
                            obj.showProgress(i, totalComputations);
                            obj.checkForStopFlag();
                            
                        end
                    end
                end
            end
        end
        
        function FinalResult = CalculateRadexLVGPopulation(obj, OuterPopulationRequest)
            
            [MoleculeData, BetaProvider, innerRequest, FinalResult] = obj.initialize (OuterPopulationRequest);
            PopulationRequest = FinalResult.OriginalRequest;
            
            totalComputations = numel(PopulationRequest.VelocityDerivative)*numel(PopulationRequest.Temperature)*numel(PopulationRequest.CollisionPartnerDensities)*...
                numel(PopulationRequest.MoleculeAbundanceRatios)*numel(PopulationRequest.ConstantNpartnerBydVdR);
            
            i = 0;
            
            for dvDrIndex=1:numel(PopulationRequest.VelocityDerivative)
                for tempIndex=1:numel(PopulationRequest.Temperature)
                    for molAbundanceIndex=1:numel(PopulationRequest.MoleculeAbundanceRatios)
                        for collPartnerDensityIndex=1:numel(PopulationRequest.CollisionPartnerDensities)
                            for constantNpartnerBydVdRIndex=1:numel(PopulationRequest.ConstantNpartnerBydVdR)
                            
                                PopulationSolverHelper.fillInnerRequest(innerRequest,PopulationRequest.Temperature(tempIndex),PopulationRequest.VelocityDerivative(dvDrIndex),PopulationRequest.VelocityDerivativeUnits,...
                                    PopulationRequest.CollisionPartnerDensities(collPartnerDensityIndex),PopulationRequest.MoleculeAbundanceRatios(molAbundanceIndex),...
                                    PopulationRequest.ConstantNpartnerBydVdR(constantNpartnerBydVdRIndex), PopulationRequest.FirstPopulationGuess);
                                
                                [ Result, Converged, RuntimeMessage ] = RadexSolver.CalculateLVGPopulation(innerRequest);
                                
                                FinalResult.Converged(tempIndex,collPartnerDensityIndex,dvDrIndex,molAbundanceIndex,constantNpartnerBydVdRIndex) = Converged;
                                
                                if Converged
                                    
                                    FinalResult.Population(1:numel(Result.Population),tempIndex,collPartnerDensityIndex,dvDrIndex,molAbundanceIndex,constantNpartnerBydVdRIndex) = Result.Population;
                                    FinalResult.FinalTauCoefficients(2:end,tempIndex,collPartnerDensityIndex,dvDrIndex,molAbundanceIndex,constantNpartnerBydVdRIndex) = Result.Tau(1:PopulationRequest.NumLevelsForSolution-1);
                                    FinalResult.Intensities(2:end,tempIndex,collPartnerDensityIndex,dvDrIndex,molAbundanceIndex,constantNpartnerBydVdRIndex) = Result.Flux_erg_cm2_s(1:PopulationRequest.NumLevelsForSolution-1)/4/Constants.pi;
                                    FinalResult.IntensitiesTempUnit(2:end,tempIndex,collPartnerDensityIndex,dvDrIndex,molAbundanceIndex,constantNpartnerBydVdRIndex) = Result.Flux_K_km_s(1:PopulationRequest.NumLevelsForSolution-1)/4/Constants.pi;
                                    FinalResult.ExcitationTemperature(2:end,tempIndex,collPartnerDensityIndex,dvDrIndex,molAbundanceIndex,constantNpartnerBydVdRIndex) = Result.ExcitationTemperature(1:PopulationRequest.NumLevelsForSolution-1);
                                    
                                end
                                
                                i=i+1;
                                obj.showProgress(i, totalComputations);
                                obj.checkForStopFlag();
                                
                            end
                        end
                    end
                end
            end
        end
        
        function FinalResult = ProcessPopulationRequest (obj, PopulationRequest)
            
            obj.ProgressFraction = 0;
            obj.StopOperation = 0;
            
            switch PopulationRequest.RunTypeCode
                
                case RunTypeCodes.LVG
                    FinalResult = obj.CalculateLVGPopulation(PopulationRequest);
                    %FinalResult = obj.CalculateLVGPopulationDensityParallel(PopulationRequest);
                    
                case {RunTypeCodes.OpticallyThin, RunTypeCodes.OpticallyThinWithBackground, RunTypeCodes.LTE}
                    FinalResult = obj.CalculateNonLVGPopulation(PopulationRequest);
                    
                case RunTypeCodes.Radex
                    FinalResult = obj.CalculateRadexLVGPopulation(PopulationRequest);
                    
                otherwise
                    ME = MException('VerifyInput:UnknownRunTypeCode','Error in input. Run Type Code [%d] is unknown', PopulationRequest.RunTypeCode);
                    throw(ME);
            end
            
            PopulationRequest.Finished = true;
            
        end
        
    end
    
    methods (Access=private)
        
        function showProgress(obj, Iteration, TotalComputations)
            
            progress = Iteration/TotalComputations;
            progressPercent = floor(100*progress);
            
            if TotalComputations > 1
                
                if Iteration==1
                    fprintf(1, 'Progress: %%%3d', progressPercent);
                else
                    fprintf(1, '\b\b\b%3d', progressPercent);
                end
                
                if Iteration==TotalComputations
                    fprintf(1, '\n');
                end
            end
            
            obj.ProgressFraction = progress;
            
        end
        
        function checkForStopFlag (obj)
            
            if obj.StopOperation
                error('PopulationSolverHelper:OperationTerminated', 'Operation terminated by user.');
            end
            
        end
                
    end
    
    methods (Access=private, Static=true)
        
        function [MoleculeData, BetaProvider, innerRequest, FinalResult] = initialize(OriginalPopulationRequest)
            
            PopulationSolverHelper.validateInput(OriginalPopulationRequest);
            [MoleculeData, BetaProvider, innerRequest, SaveableRequest] = PopulationSolverHelper.changeRequestToInnerRequest (OriginalPopulationRequest);
            FinalResult = PopulationSolverHelper.initializeResult(SaveableRequest);
            
        end
        
        function fillInnerRequest(InnerRequest, Temperature, VelocityDerivative, VelocityDerivativeUnit, CollisionPartnerDensities, MoleculeAbundanceRatios, ConstantNpartnerBydVdR, FirstPopulationGuess)
            
            InnerRequest.FirstPopulationGuess = [];
            InnerRequest.Temperature = Temperature;
            InnerRequest.VelocityDerivativeUnits = VelocityDerivativeUnits.sec;
            InnerRequest.VelocityDerivative = VelocityDerivative * VelocityDerivativeUnits.ConversionFactorToCGS(VelocityDerivativeUnit);
            InnerRequest.CollisionPartnerDensities = CollisionPartnerDensities;
            InnerRequest.FirstPopulationGuess = FirstPopulationGuess;
            InnerRequest.MoleculeAbundanceRatios = MoleculeAbundanceRatios;
            
            if ~isempty(ConstantNpartnerBydVdR) && ConstantNpartnerBydVdR ~= 0
                if CollisionPartnerDensities == 0
                    InnerRequest.CollisionPartnerDensities = ConstantNpartnerBydVdR*InnerRequest.VelocityDerivative;
                elseif VelocityDerivative == 0
                    InnerRequest.VelocityDerivative = CollisionPartnerDensities/ConstantNpartnerBydVdR;
                end
            end
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
                numel(PopulationRequest.CollisionPartnerDensities), numel(PopulationRequest.VelocityDerivative), numel(PopulationRequest.MoleculeAbundanceRatios), numel(PopulationRequest.ConstantNpartnerBydVdR));
            dimensions = size(FinalResult.Population);
            FinalResult.FinalBetaCoefficients = zeros(dimensions);
            FinalResult.FinalTauCoefficients = zeros(dimensions);
            FinalResult.Intensities = zeros(dimensions);
            FinalResult.IntensitiesTempUnit = zeros(dimensions);
            FinalResult.ExcitationTemperature = zeros(dimensions);
            FinalResult.Converged = zeros(dimensions(2:end));
            
        end
        
        function [Molecule, BetaProvider, InternalPopulationRequest, SaveableRequest] = changeRequestToInnerRequest (PopulationRequest)
            
            SaveableRequest = PopulationRequest.Copy();
            
            Molecule = WorkspaceHelper.GetMoleculeDataFromWorkspace(SaveableRequest.MoleculeFileName);
            BetaProvider = PopulationSolverHelper.createBetaProvider(SaveableRequest.BetaTypeCode, Molecule, SaveableRequest.BackgroundTemperature);
            
            if isempty(SaveableRequest.NumLevelsForSolution) || SaveableRequest.NumLevelsForSolution == 0
                SaveableRequest.NumLevelsForSolution = Molecule.MolecularLevels;
            end
            
            if isempty(SaveableRequest.Temperature) || (isscalar(SaveableRequest.Temperature) && SaveableRequest.Temperature == 0)
                collPartners = Molecule.CollisionPartnerCodes();
                SaveableRequest.Temperature = Molecule.GetCollisionPartner(collPartners(1)).Temperatures;
            end
            
            InternalPopulationRequest = SaveableRequest.Copy();
            
            PopulationSolverHelper.replaceCollisionPartnerCodesToRates(InternalPopulationRequest,Molecule);
            
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
        
    end
    
end