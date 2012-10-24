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
            
            RadiationClc = RadiationCalculator(MoleculeData, OuterPopulationRequest.BackgroundTemperature~=0, OuterPopulationRequest.BackgroundTemperature);
            
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
                                    PopulationRequest.ConstantNpartnerBydVdR(constantNpartnerBydVdRIndex), PopulationRequest.CollisionPartnerColumnDensity, PopulationRequest.FirstPopulationGuess);
                                
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
                                    
                                    FinalResult.IntegratedIntensity(:,tempIndex,collPartnerDensityIndex,dvDrIndex,molAbundanceIndex,constantNpartnerBydVdRIndex) = RadiationClc.CalculateIntegratedIntensityLVG(Result.Population, ...
                                        Result.FinalTauCoefficients, PopulationRequest.MoleculeAbundanceRatios(molAbundanceIndex), PopulationRequest.CollisionPartnerColumnDensity);
                                    FinalResult.ExcitationTemperature(:,tempIndex,collPartnerDensityIndex,dvDrIndex,molAbundanceIndex,constantNpartnerBydVdRIndex) = ...
                                        RadiationClc.CalculateExcitationTemperature(Result.Population);
                                    FinalResult.IntegratedIntensityTempUnits(:,tempIndex,collPartnerDensityIndex,dvDrIndex,molAbundanceIndex,constantNpartnerBydVdRIndex) = ...
                                        RadiationClc.CalculateIntegratedIntensityInTemperatureUnits(Result.Population, Result.FinalTauCoefficients, ...
                                        PopulationRequest.MoleculeAbundanceRatios(molAbundanceIndex), PopulationRequest.CollisionPartnerColumnDensity);
                                    FinalResult.RadiationTemeperature(:,tempIndex,collPartnerDensityIndex,dvDrIndex,molAbundanceIndex,constantNpartnerBydVdRIndex) = ...
                                        RadiationClc.CalculateRadiationTemperature(Result.Population, Result.FinalTauCoefficients);
                                    
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
            
            RadiationClc = RadiationCalculator(MoleculeData, OuterPopulationRequest.BackgroundTemperature~=0, OuterPopulationRequest.BackgroundTemperature);
            
            FinalResult.Converged = ones(size(FinalResult.Converged));
            FinalResult.FinalBetaCoefficients = ones(size(FinalResult.FinalBetaCoefficients));
            FinalResult.FinalTauCoefficients = zeros(size(FinalResult.FinalTauCoefficients));
            
            totalComputations = numel(PopulationRequest.VelocityDerivative)*numel(PopulationRequest.Temperature)*...
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
                                    PopulationRequest.ConstantNpartnerBydVdR(constantNpartnerBydVdRIndex), PopulationRequest.CollisionPartnerColumnDensity, PopulationRequest.FirstPopulationGuess);
                                
                                Population = solver.SolveLevelsPopulation(innerRequest);
                                
                                FinalResult.Population(:,tempIndex,collPartnerDensityIndex,dvDrIndex,molAbundanceIndex,constantNpartnerBydVdRIndex) = Population;
                                
                                if PopulationRequest.RunTypeCode == RunTypeCodes.LTE
                                    FinalResult.IntegratedIntensity(:,tempIndex,collPartnerDensityIndex,dvDrIndex,molAbundanceIndex,constantNpartnerBydVdRIndex) = RadiationClc.CalculateFluxLTE(PopulationRequest.Temperature(tempIndex),...
                                        PopulationRequest.MoleculeAbundanceRatios(molAbundanceIndex));
                                else
                                    FinalResult.IntegratedIntensity(:,tempIndex,collPartnerDensityIndex,dvDrIndex,molAbundanceIndex,constantNpartnerBydVdRIndex) = RadiationClc.CalculateIntegratedIntensityLVG(Population, ...
                                        FinalResult.FinalTauCoefficients(:,tempIndex,collPartnerDensityIndex,dvDrIndex,molAbundanceIndex,constantNpartnerBydVdRIndex), PopulationRequest.MoleculeAbundanceRatios(molAbundanceIndex), PopulationRequest.CollisionPartnerColumnDensity);                                    
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
                                    PopulationRequest.ConstantNpartnerBydVdR(constantNpartnerBydVdRIndex), PopulationRequest.CollisionPartnerColumnDensity, PopulationRequest.FirstPopulationGuess);
                                
                                [ Result, Converged, RuntimeMessage ] = RadexSolver.CalculateLVGPopulation(innerRequest);
                                
                                FinalResult.Converged(tempIndex,collPartnerDensityIndex,dvDrIndex,molAbundanceIndex,constantNpartnerBydVdRIndex) = Converged;
                                
                                if Converged
                                    
                                    FinalResult.Population(1:numel(Result.Population),tempIndex,collPartnerDensityIndex,dvDrIndex,molAbundanceIndex,constantNpartnerBydVdRIndex) = Result.Population;
                                    FinalResult.FinalTauCoefficients(2:end,tempIndex,collPartnerDensityIndex,dvDrIndex,molAbundanceIndex,constantNpartnerBydVdRIndex) = Result.Tau(1:PopulationRequest.NumLevelsForSolution-1);
                                    FinalResult.Flux(2:end,tempIndex,collPartnerDensityIndex,dvDrIndex,molAbundanceIndex,constantNpartnerBydVdRIndex) = Result.Flux_erg_cm2_s(1:PopulationRequest.NumLevelsForSolution-1);
                                    FinalResult.FluxTempUnits(2:end,tempIndex,collPartnerDensityIndex,dvDrIndex,molAbundanceIndex,constantNpartnerBydVdRIndex) = Result.Flux_K_km_s(1:PopulationRequest.NumLevelsForSolution-1);
                                    FinalResult.ExcitationTemperature(2:end,tempIndex,collPartnerDensityIndex,dvDrIndex,molAbundanceIndex,constantNpartnerBydVdRIndex) = Result.ExcitationTemperature(1:PopulationRequest.NumLevelsForSolution-1);
                                    FinalResult.RadiationTemeperature(2:end,tempIndex,collPartnerDensityIndex,dvDrIndex,molAbundanceIndex,constantNpartnerBydVdRIndex) = Result.RadiationTemeperature(1:PopulationRequest.NumLevelsForSolution-1);
                                    
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
        
        function fillInnerRequest(InnerRequest, Temperature, VelocityDerivative, VelocityDerivativeUnit, CollisionPartnerDensities, MoleculeAbundanceRatios, ...
                ConstantNpartnerBydVdR, CollisionPartnerColumnDensity, FirstPopulationGuess)
            
            InnerRequest.FirstPopulationGuess = [];
            InnerRequest.Temperature = Temperature;
            InnerRequest.VelocityDerivativeUnits = VelocityDerivativeUnits.sec;
            InnerRequest.VelocityDerivative = VelocityDerivative * VelocityDerivativeUnits.ConversionFactorToCGS(VelocityDerivativeUnit);
            InnerRequest.CollisionPartnerDensities = CollisionPartnerDensities;
            InnerRequest.FirstPopulationGuess = FirstPopulationGuess;
            InnerRequest.MoleculeAbundanceRatios = MoleculeAbundanceRatios;
            InnerRequest.CollisionPartnerColumnDensity = CollisionPartnerColumnDensity;
            InnerRequest.ConstantNpartnerBydVdR = ConstantNpartnerBydVdR;
            
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
            FinalResult.IntegratedIntensity = zeros(dimensions);
            FinalResult.IntegratedIntensityTempUnits = zeros(dimensions);
            FinalResult.Flux = zeros(dimensions);
            FinalResult.FluxTempUnits = zeros(dimensions);
            FinalResult.ExcitationTemperature = zeros(dimensions);
            FinalResult.RadiationTemeperature = zeros(dimensions);
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
                
                collisionPartner = MoleculeData.GetCollisionPartner(collisionPartnerCodes(i));
                
                if ~isempty(collisionPartner)
                    collisionPartnerRates(i) = collisionPartner;
                else
                    names = MoleculeData.CollisionPartnerNames();
                    namesLine = FileIOHelper.ConcatWithSeperator(names, ', ');
                    ME = MException('VerifyInput:collisionPartnerMismatch','Error in input. The collision partner you selected does not exist for molecule "%s". Possible values: %s', MoleculeData.MoleculeFileName, namesLine{:});
                    throw(ME);
                end
                
            end
            
            PopulationRequest.CollisionPartners = collisionPartnerRates;
            
        end
        
    end
    
end
