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

classdef Scripts
    
    methods (Access=public, Static=true)
        
        function [Ratios, RatiosTitles] = CalculateIntensityRatios(PopulationResultPairs, LevelPairs)
            
            if size(PopulationResultPairs,2)~=2 || size(LevelPairs,2)~=2
                ME = MException('CalculateIntensityRatios:InputArgumentError','Error in input. Input matrices should contain two columns');
                throw(ME);
            elseif size(PopulationResultPairs,1)~=size(LevelPairs,1)
                ME = MException('CalculateIntensityRatios:InputArgumentError','Error in input. PopulationResultPairs and LevelPairs should contain the same number of rows');
                throw(ME);
            end
            
            for i=1:size(PopulationResultPairs,1)
                if ~LVGSolverPopulationRequest.EqualParameterSpace(PopulationResultPairs(i,1).OriginalRequest,PopulationResultPairs(i,2).OriginalRequest)
                    ME = MException('CalculateIntensityRatios:InputArgumentError','Error in input. All results in PopulationResultArray should be on the same parameter space. Problematic pair index: %g', i);
                    throw(ME);
                end
            end
            
            dummyIntensity = PopulationResultPairs(1).IntegratedIntensity;
            Ratios = zeros(size(dummyIntensity,2),size(dummyIntensity,3),size(dummyIntensity,4),size(dummyIntensity,5),size(dummyIntensity,6),size(LevelPairs,1));
            RatiosTitles = cell(1,size(LevelPairs,1));
            
            for pairsIndex=1:size(LevelPairs,1)
                
                UpperIntensity = PopulationResultPairs(pairsIndex,1).IntegratedIntensity;
                LowerIntensity = PopulationResultPairs(pairsIndex,2).IntegratedIntensity;
                
                UpperMolecule = WorkspaceHelper.GetMoleculeDataFromWorkspace(PopulationResultPairs(pairsIndex,1).OriginalRequest.MoleculeFileName);
                LowerMolecule = WorkspaceHelper.GetMoleculeDataFromWorkspace(PopulationResultPairs(pairsIndex,2).OriginalRequest.MoleculeFileName);
                
                UpperIntensityLevelIndex = LevelPairs(pairsIndex,1);
                LowerIntensityLevelIndex = LevelPairs(pairsIndex,2);
                
                Ratios(:,:,:,:,:,pairsIndex) = squeeze(UpperIntensity(UpperIntensityLevelIndex,:,:,:,:,:)./LowerIntensity(LowerIntensityLevelIndex,:,:,:,:,:));
                RatiosTitles{pairsIndex} = sprintf('Ratio: %s(%d-%d)/%s(%d-%d)', UpperMolecule.MoleculeName, UpperIntensityLevelIndex-1, UpperIntensityLevelIndex-2,...
                    LowerMolecule.MoleculeName, LowerIntensityLevelIndex-1,LowerIntensityLevelIndex-2);
                
            end
            
        end
                
        function [Ratio, RatiosTitle, NominatorData, DenominatorData] = CalculateResultsRatio(PopulationResultPair, LevelPair, ...
                PropertiesAndIndicesPairsNominator, PropertiesAndIndicesPairsDenominator, ComparisonTypeCode, XAxisProperty, YAxisProperty)
            
            if size(PopulationResultPair,2)~=2 || size(LevelPair,2)~=2
                ME = MException('CalculateIntensityRatios:InputArgumentError','Error in input. Input matrices should contain two columns');
                throw(ME);
            elseif size(PopulationResultPair,1)~= 1 && size(LevelPair,1) ~= 1
                ME = MException('CalculateIntensityRatios:InputArgumentError','Error in input. PopulationResultPairs and LevelPairs should contain exactly one row');
                throw(ME);
            end
            
            for i=1:size(PopulationResultPair,1)
                if ~LVGSolverPopulationRequest.EqualParameterSpace(PopulationResultPair(i,1).OriginalRequest,PopulationResultPair(i,2).OriginalRequest)
                    ME = MException('CalculateIntensityRatios:InputArgumentError','Error in input. All results in PopulationResultArray should be on the same parameter space.');
                    throw(ME);
                end
            end
            
            % Extract data
            UpperValues = ComparisonTypeCodes.GetLVGResultsValue(PopulationResultPair(1,1),ComparisonTypeCode);
            UpperValues = Scripts.ExtractDataFromResultsDataset(UpperValues, PropertiesAndIndicesPairsNominator);
            
            LowerValues = ComparisonTypeCodes.GetLVGResultsValue(PopulationResultPair(1,2),ComparisonTypeCode);
            LowerValues = Scripts.ExtractDataFromResultsDataset(LowerValues, PropertiesAndIndicesPairsDenominator);
            
            UpperValuesLevelIndex = LevelPair(1,1);
            LowerValuesLevelIndex = LevelPair(1,2);
            
            NominatorData = squeeze(UpperValues(UpperValuesLevelIndex,:,:));
            DenominatorData = squeeze(LowerValues(LowerValuesLevelIndex,:,:));
            
            [NominatorData, DenominatorData] = Scripts.AdjustDataSizeWhenSelectingMoleculeAbundanceRatiosAsAxis(NominatorData, DenominatorData, ...
               XAxisProperty, YAxisProperty, PropertiesAndIndicesPairsNominator, PropertiesAndIndicesPairsDenominator);
            
            Ratio = NominatorData./DenominatorData;

            if YAxisProperty > XAxisProperty
                Ratio = Ratio';
                NominatorData = NominatorData';
                DenominatorData = DenominatorData';
            end
            
            %Build title
            UpperMolecule = WorkspaceHelper.GetMoleculeDataFromWorkspace(PopulationResultPair(1,1).OriginalRequest.MoleculeFileName);
            LowerMolecule = WorkspaceHelper.GetMoleculeDataFromWorkspace(PopulationResultPair(1,2).OriginalRequest.MoleculeFileName);
            
            RatiosTitle = {sprintf('Ratio: %s(%d-%d)/%s(%d-%d)', UpperMolecule.MoleculeName, UpperValuesLevelIndex-1, UpperValuesLevelIndex-2,...
                LowerMolecule.MoleculeName, LowerValuesLevelIndex-1,LowerValuesLevelIndex-2)};
            
        end
        
        function [NominatorData, DenominatorData] = AdjustDataSizeWhenSelectingMoleculeAbundanceRatiosAsAxis(NominatorData, DenominatorData, ...
               XAxisProperty, YAxisProperty, PropertiesAndIndicesPairsNominator, PropertiesAndIndicesPairsDenominator)    
            %If the selected axis is one of the MoleculeAbundanceRatios (either nominator or denominator), we need 
            %to adjust the size of the other data matrix to fit the proper size
            if (PropertiesAndIndicesPairsNominator(LVGParameterCodes.MoleculeAbundanceRatio,2) < 0)
                if (LVGParameterCodes.MoleculeAbundanceRatio > YAxisProperty || ...
                        LVGParameterCodes.MoleculeAbundanceRatio > XAxisProperty)
                    DenominatorData = repmat(DenominatorData', 1, size(NominatorData,2));
                else
                    DenominatorData = repmat(DenominatorData, size(NominatorData,1), 1);
                end                
            elseif (PropertiesAndIndicesPairsDenominator(LVGParameterCodes.MoleculeAbundanceRatio,2) < 0)
                if (LVGParameterCodes.MoleculeAbundanceRatio > YAxisProperty || ...
                        LVGParameterCodes.MoleculeAbundanceRatio > XAxisProperty)
                    NominatorData = repmat(NominatorData', 1, size(DenominatorData,2));
                else
                    NominatorData = repmat(NominatorData, size(DenominatorData,1), 1);
                end
            end
        end
        
        function [Result] = ExtractDataFromResultsDataset (Data, PropertiesAndIndicesPairs)
            
            Properties = PropertiesAndIndicesPairs(:,1);
            Indices = PropertiesAndIndicesPairs(:,2);
            FetchString = ':,';
           
            for i = 1:max(Properties)
                index = Indices(Properties==i);             
                
                if index > 0
                    FetchString = [FetchString, num2str(index), ','];                    
                else
                    FetchString = [FetchString, ':', ','];
                end                
            end
            
            FetchString = ['(', FetchString(1:end-1), ')'];            
            Result = eval(['Data', FetchString]);
            Result = squeeze(Result);
            
        end
        
        function [XData, YData, ZData] = DrawContours(Data, DataTitles, ContourLevels, XAxisTitle, XData, YAxisTitle, YData, PlotTypeCode, varargin)
            
            p = inputParser;   % Create instance of inputParser class.
            p.addParamValue('XData', XData, @isnumeric);
            p.addParamValue('xName', XAxisTitle, @ischar);
            p.addParamValue('YData', YData, @isnumeric);
            p.addParamValue('yName', YAxisTitle, @ischar);
            p.addParamValue('titleName', '', @ischar);
            p.addParamValue('XScale', 'log', @(x)any(strcmpi(x,{'log','linear'})));
            p.addParamValue('YScale', 'log', @(x)any(strcmpi(x,{'log','linear'})));
            p.addParamValue('snapPlot', true, @(x)isscalar(x)&&islogical(x));
            p.addParamValue('axesHandle', 0, @(x)ishandle(x));
            p.addParamValue('toggleLegend', true, @(x)isscalar(x)&&islogical(x));
            p.addParamValue('displayTitle', true, @(x)isscalar(x)&&islogical(x));
            p.addParamValue('displayColorbar', false, @(x)isscalar(x)&&islogical(x));
            p.parse(varargin{:});
       
            ZData = zeros(numel(p.Results.YData), numel(p.Results.XData), size(Data,6));
            
            drawInsideForm = p.Results.axesHandle ~= 0;
            
            if ~drawInsideForm
                figure;
            end
            
            plotPtr = PlotTypeCodes.GetFunctionPointer(PlotTypeCode);
            
            for i=1:size(Data,6)
                z = squeeze(Data(:,:,:,:,:,i));
                ZData (:,:,i) = z;
                
                if ~drawInsideForm
                    [C,h] = plotPtr (p.Results.XData, p.Results.YData, z, ContourLevels{i}, Scripts.lineStyleChooser(i)); hold all;
                else
                    [C,h] = plotPtr (p.Results.axesHandle, p.Results.XData, p.Results.YData, z, ContourLevels{i}, Scripts.lineStyleChooser(i)); hold all;
                end
                
                hGroup = hggroup;
                set(h,'Parent',hGroup);
                set(get(get(hGroup,'Annotation'),'LegendInformation'),'IconDisplayStyle','on');
                set(hGroup,'DisplayName', DataTitles{i});
                %if (numel(ContourLevels{i})>1); clabel(C,h,'Rotation',0);
                %end;
            end
            
            hold off;
           
            set(gca,'XScale',p.Results.XScale);
            set(gca, 'YScale', p.Results.YScale);
            xlabel(p.Results.xName);
            ylabel(p.Results.yName);
            
            if (p.Results.displayColorbar); colorbar; else colorbar('delete'); end
            if (p.Results.displayTitle); title(p.Results.titleName); end
            if (p.Results.toggleLegend); legend('toggle'); end
        end
        
        function NCritical = DrawCriticalDensities(Temperature, MoleculeData, CollisionRates)
            
            NCritical = zeros(MoleculeData.MolecularLevels,1);
            
            for i=2:MoleculeData.MolecularLevels
                
                A = MoleculeData.EinsteinACoefficient(i,i-1);
                qSum = 0;
                
                for j = 1:i-1
                    qSum = qSum + CollisionRates.CollisionRateCoefficient(i,j,Temperature);
                end
                
                NCritical(i) = A/qSum;
            end
            
            plot(0:(MoleculeData.MolecularLevels-1), NCritical, 'DisplayName', 'Critical Densities'); figure(gcf)
            title(sprintf('Critical Densities. T=%dK', Temperature));
            xlabel('J');            
            ylabel('n_c_r_i_t [cm^-^3]');
            set(gca, 'YScale', 'log');
            
        end
        
        function DrawCollisionRateCoefficients(Temperature, CollisionRates, NumContourLevels)
            
            rates = CollisionRates.CollisionRateCoefficientMatrix(Temperature);
            
            contour3(rates,NumContourLevels); figure(gcf)
            
            xlabel('Final Level');
            ylabel('Initial Level');
            zlabel('q [cm^3 s^-^1]');
            
            title(sprintf('Collision Rate Coefficients. T=%dK', Temperature));
            
        end
        
        function CompareResults (Data, PlotArguments, XLabel, YLabel, YRange, YAxisLog, Title, FigureBehavior, FileName)
            
            p = inputParser;   % Create instance of inputParser class.
            p.addRequired('FigureBehavior', @(x)any(strcmpi(x,{'OpenNew','UseOld','Add'})));
            p.parse(FigureBehavior);
            
            maxSize=0;
            %find max
            for i=1:numel(Data)
               maxSize = max(maxSize, numel(Data{i}));
            end
    
            ResizedData = NaN(maxSize, numel(Data));
            for i=1:numel(Data)
                ResizedData(1:numel(Data{i}),i) = Data{i};
            end
            
            xValues = 0:(maxSize-1);

            switch p.Results.FigureBehavior
                case 'OpenNew'
                    figure;
                case 'UseOld'               
                    %do nothing;
                case 'Add'
                    hold all;
            end
            
            %draw
            for i=1:numel(Data)                
                args = PlotArguments{i};
                h = plot(xValues, ResizedData(:,i), args{:});                
                if i==1; hold all; end
            end
                        
            hold off;
            
            figure(gcf);
            
            xlabel(XLabel);
            ylabel(YLabel);
            
            title(Title);
           
            if ~isempty(YRange); axis([0 maxSize-1 YRange]); end
            if YAxisLog; set(gca, 'YScale', 'log'); end
            
            %if plot contains non unit x axis ticks, replace them with the 
            %proper ticks.
            ticks = get(gca,'XTick');
            if any(~(floor(ticks)==ticks))
                set(gca,'XTick',xValues)
            end
            
            set(gca,'XMinorTick', 'on');
            
            legend('show');
            
            if ~isempty(FileName)
                saveas (h,FileName);
            end
        end
        
        function DrawResults1Molecule (DrawType, PopulationResult, VelocityDerivativeIndices, TemperatureIndices, CollisionPartnerDensitiesIndices, MoleculeAbundanceIndices, FigureBehavior, FileName)
            
            p = inputParser;    % Create an instance of the class.
            p.addRequired('DrawType', @(x)isnumeric(x) && isscalar(x));
            p.addRequired('PopulationResult', @(x)isa(x,'LVGSolverPopulationResult'));
            p.addRequired('VelocityDerivativeIndices', @(x)isnumeric(x));
            p.addRequired('TemperatureIndices', @(x)isnumeric(x));
            p.addRequired('CollisionPartnerDensitiesIndices', @(x)isnumeric(x));
            p.addRequired('FileName', @ischar);
            p.parse(DrawType, PopulationResult, VelocityDerivativeIndices, TemperatureIndices, CollisionPartnerDensitiesIndices, FileName);
            
            [Data,xaxis,yaxis,YRange,YAxisLog] = Scripts.buildResultDisplayData(DrawType, PopulationResult);
            
            request = PopulationResult.OriginalRequest;
            
            RefinedData = cell(1,0);
            PlotArguments = cell(1,0);
            
            for tempIndex=TemperatureIndices
                for densityIndex=CollisionPartnerDensitiesIndices
                    for dvdrIndex=VelocityDerivativeIndices
                        for molAbundanceIndex=MoleculeAbundanceIndices
                            
                            displayName = Scripts.buildSEDDisplayName(request.VelocityDerivative(VelocityDerivativeIndices), dvdrIndex, request.VelocityDerivativeUnits,...
                                request.Temperature(TemperatureIndices), tempIndex, request.CollisionPartnerDensities(CollisionPartnerDensitiesIndices), densityIndex, ...
                                request.MoleculeAbundanceRatios(MoleculeAbundanceIndices), molAbundanceIndex, [], 0);
                            
                            RefinedData{end+1} = Data(:,tempIndex,densityIndex,dvdrIndex,molAbundanceIndex);
                            PlotArguments{end+1} = {'DisplayName', displayName};
                        end
                    end
                end
            end
            
            titleName = Scripts.buildSEDTitleName(request.VelocityDerivative(VelocityDerivativeIndices), request.VelocityDerivativeUnits,...
                request.Temperature(TemperatureIndices), request.CollisionPartnerDensities(CollisionPartnerDensitiesIndices), ...
                request.MoleculeAbundanceRatios(MoleculeAbundanceIndices), []);
            
            Scripts.CompareResults(RefinedData, PlotArguments, xaxis, yaxis, YRange, YAxisLog, titleName, FigureBehavior, FileName);
            
        end

        function CalculatedTemp = DrawBoltzmannFit (PopulationResult, VelocityDerivativeIndex, TemperatureIndex, CollisionPartnerDensitiesIndex)
            
            request = PopulationResult.OriginalRequest;
            lteReq = request.Copy();
            lteReq.RunTypeCode = RunTypeCodes.LTE;
            lteReq.VelocityDerivative = lteReq.VelocityDerivative(VelocityDerivativeIndex);
            lteReq.Temperature = lteReq.Temperature(TemperatureIndex);
            lteReq.CollisionPartnerDensities = lteReq.CollisionPartnerDensities(CollisionPartnerDensitiesIndex);
            lteReq.MoleculeDensity = lteReq.MoleculeDensity(CollisionPartnerDensitiesIndex);
            lteReq.CloudColumnDensity = lteReq.CloudColumnDensity(CollisionPartnerDensitiesIndex);
            solver = PopulationSolverHelper();
            lteResult = solver.ProcessPopulationRequest(lteReq);   
            
            LTEPopulation = lteResult.Population;
            Population = PopulationResult.Population(:,TemperatureIndex,CollisionPartnerDensitiesIndex,VelocityDerivativeIndex);
            MoleculeData = WorkspaceHelper.GetMoleculeDataFromWorkspace(lteReq.MoleculeFileName);
            
            logRatio = zeros(MoleculeData.MolecularLevels,1);
            energies = zeros(MoleculeData.MolecularLevels,1);
            
            LTElogRatio = zeros(MoleculeData.MolecularLevels,1);
            
            for i = 2:MoleculeData.MolecularLevels
                g = MoleculeData.StatisticalWeight(i);
                
                logRatio(i,1) = log(Population (i,1)/(Population (1,1)*g));
                LTElogRatio(i,1) = log(LTEPopulation (i,1)/(LTEPopulation (1,1)*g));
                
                energies(i,1) = MoleculeData.TransitionEnergy(i, 1);
            end
            
            p = polyfit(energies,logRatio,1);
            CalculatedTemp = - 1/(p(1,1)*Constants.k);
            
            plot(energies, logRatio, 'DisplayName', 'Log of population ratios vs Energies');
            hold all;
            plot(energies, LTElogRatio, 'DisplayName', 'LTE Reference');
            hold off; figure(gcf);
            
            titleName = Scripts.buildSEDTitleName(request.VelocityDerivative(VelocityDerivativeIndex), request.VelocityDerivativeUnits,...
                request.Temperature(TemperatureIndex), request.CollisionPartnerDensities(CollisionPartnerDensitiesIndex), ...
                request.MoleculeDensity(CollisionPartnerDensitiesIndex), []);
            
            fitTitle = sprintf('. Fitted Temperature=%gK', CalculatedTemp);
            
            titleName = strcat(titleName, fitTitle);
            title(titleName);
            
            xlabel('Energies [erg]');
            ylabel('log[X_j/(X_0*G_j)]');
            
            legend('toggle');
            
        end

        
        
        function CompareWithMeasurement (Measurement, Population, CollisionPartnerDensity, Temperature, VelocityDerivative, VelocityDerivativeUnit, MoleculeDensity, ColumnDensity, FileName)
                    
            maxSize = max([numel(Measurement) numel(Population)]);
            
            if (numel(Measurement) < maxSize)
                Measurement = cat(1, Measurement, zeros(maxSize - numel(Measurement),1));
            end
            
            if (numel(Population) < maxSize)
                Population = cat(1, Population, zeros(maxSize - numel(Population)));
            end
            
            xValues = 0:(maxSize-1);
            
            plot(xValues, Population, '--', 'DisplayName', 'LVG Model - '); hold all;
            h = plot(xValues, Measurement, 'xk', ...
                'LineWidth',2,...
                'MarkerSize',10,...
                'DisplayName', 'Measurement'); %hold all;
            
            hold off;
            figure(gcf);
            
            xlabel('J_u_p_p_e_r');
            %ylabel('x - Fractional population');
            ylabel('Intensity [W m^-^2]');
            
            titleName = Scripts.buildSEDTitleName(VelocityDerivative, VelocityDerivativeUnit, Temperature, CollisionPartnerDensity, MoleculeDensity, ColumnDensity);
            title(titleName);
            %axis([0 maxSize-1 0 1]);
            %set(gca,'XTick',xValues)
            
            legend('toggle');
            
            if nargin > 5 && ~isempty(FileName)
                saveas (h,FileName);
            end
        end
                
        function Diff = PopulationDiff (pop1, pop2)
            
            minLength = min(numel(pop1), numel(pop2));
            maxPopArr = max (pop1, pop2);
            maxPop = max(maxPopArr);
            
            % Calculate difference between codes
            pop1 = pop1(1:minLength);
            pop2 = pop2(1:minLength);
            
            smallPop = maxPop*1e-3;
            smallIndices = pop1 < smallPop & pop2 < smallPop;
            
            pop1(smallIndices) = 0;
            pop2(smallIndices) = 0;
            
            Diff = (abs(pop1-pop2)./mean(maxPopArr(~smallIndices)));
        end
        
        function DrawMax1Molecule(PopulationResult, ContourLevels)
            originalRequest = PopulationResult.OriginalRequest;
            
            %only one of the three:dvdrKmParsecs, Densities, Temperatures,
            %should contain one element
            if (Scripts.onlyOneIsSingle(originalRequest.VelocityDerivative, originalRequest.CollisionPartnerDensities, originalRequest.Temperature))
                ME = MException('DrawContours:InputArgumentError','Error in input. One of the following should be constant: dvdrKmParsecs, Densities, Temperatures');
                throw(ME);
            end
            
            [x,y,xName,yName,titleName] = Scripts.contourParameters (originalRequest.Temperature, originalRequest.CollisionPartnerDensities, originalRequest.VelocityDerivative);
            
            [values,MaxIndices] =max(PopulationResult.IntegratedIntensity);
            
            figure;
            
            for i=1:size(MaxIndices,4)
                [C,h] = contour3 (x, y, squeeze(MaxIndices(:,:,:,i)), ContourLevels{i}, Scripts.lineStyleChooser(i)); hold all;
                hGroup = hggroup;
                set(h,'Parent',hGroup);
                set(get(get(hGroup,'Annotation'),'LegendInformation'),'IconDisplayStyle','on');
                if (numel(ContourLevels{i})>1); clabel(C,h,'Rotation',0); end;
            end
            
            hold off;figure(gcf);
            
            xlabel(xName);
            ylabel(yName);
            
            title(titleName);
            legend('toggle');
            
        end
        
        function DrawContours1Molecule(PopulationResult, LevelPairs, ContourLevels)
            %Temperatures, Densities, dvdrKmParsecs, LevelPairs, ContourLevels, IntegratedIntensity, MoleculeData)
            originalRequest = PopulationResult.OriginalRequest;
            MoleculeData = WorkspaceHelper.GetMoleculeDataFromWorkspace(originalRequest.MoleculeFileName);
            
            %only one of the three:dvdrKmParsecs, Densities, Temperatures,
            %should contain one element
            if (~Scripts.onlyOneIsSingle(originalRequest.VelocityDerivative, originalRequest.CollisionPartnerDensities, originalRequest.Temperature))
                ME = MException('DrawContours:InputArgumentError','Error in input. One of the following should be constant: dvdrKmParsecs, Densities, Temperatures');
                throw(ME);
            end
            
            [x,y,xName,yName,titleName] = Scripts.contourParameters (originalRequest.Temperature, originalRequest.CollisionPartnerDensities, originalRequest.VelocityDerivative/Constants.dVdRConversionFactor);
            
            Ratios = zeros(size(PopulationResult.IntegratedIntensity,2),size(PopulationResult.IntegratedIntensity,3),size(PopulationResult.IntegratedIntensity,4),size(LevelPairs,1));
            RatiosTitles = cell(1,size(LevelPairs,1));
            
            for pairsIndex=1:size(LevelPairs,1)
                Ratios(:,:,:,pairsIndex) = squeeze(PopulationResult.IntegratedIntensity(LevelPairs(pairsIndex,1),:,:,:)./PopulationResult.IntegratedIntensity(LevelPairs(pairsIndex,2),:,:,:));
                RatiosTitles{pairsIndex} = sprintf(['Ratio: ',MoleculeData.MoleculeName,' I%d/',MoleculeData.MoleculeName, ' I%d'], [LevelPairs(pairsIndex,1),LevelPairs(pairsIndex,2)]);
            end
            
            figure;
            
            for i=1:size(Ratios,4)
                z = squeeze(Ratios(:,:,:,i));
                [C,h] = contour3 (x, y, z, ContourLevels{i}, Scripts.lineStyleChooser(i)); hold all;
                hGroup = hggroup;
                set(h,'Parent',hGroup);
                set(get(get(hGroup,'Annotation'),'LegendInformation'),'IconDisplayStyle','on');
                set(hGroup,'DisplayName', RatiosTitles{i});
                %if (numel(ContourLevels{i})>1); clabel(C,h,'Rotation',0); end;
            end
            
            hold off;figure(gcf);
            
            xlabel(xName);
            ylabel(yName);
            
            title(titleName);
            legend('toggle');
            
        end
        
        function DrawContours2Molecules(PopulationResult1, PopulationResult2, LevelPairs, ContourLevels)
            
            Intensities1 = PopulationResult1.IntegratedIntensity;
            Intensities2 = PopulationResult2.IntegratedIntensity;
            originalRequest1 = PopulationResult1.OriginalRequest;
            originalRequest2 = PopulationResult2.OriginalRequest;
            MoleculeData1 = WorkspaceHelper.GetMoleculeDataFromWorkspace(originalRequest1.MoleculeFileName);
            MoleculeData2 = WorkspaceHelper.GetMoleculeDataFromWorkspace(originalRequest2.MoleculeFileName);
            
            Ratios = zeros(size(IntegratedIntensity,2),size(IntegratedIntensity,3),size(IntegratedIntensity,4),size(LevelPairs,1));
            RatiosTitles = cell(1,size(LevelPairs,1));
            
            for pairsIndex=1:size(LevelPairs,1)
                if (LevelPairs(pairsIndex,1)~=0 && LevelPairs(pairsIndex,2)~=0)
                    Ratios(:,:,:,pairsIndex) = squeeze(Intensities1(LevelPairs(pairsIndex,1),:,:,:)./Intensities1(LevelPairs(pairsIndex,2),:,:,:));
                    RatiosTitles{pairsIndex} = sprintf(['Ratio: ',MoleculeData1.MoleculeName,' I%d/',MoleculeData1.MoleculeName, ' I%d'], [LevelPairs(pairsIndex,1),LevelPairs(pairsIndex,2)]);
                elseif (LevelPairs(pairsIndex,3)~=0 && LevelPairs(pairsIndex,4)~=0)
                    Ratios(:,:,:,pairsIndex) = squeeze(Intensities2(LevelPairs1(pairsIndex,3),:,:,:)./Intensities2(LevelPairs1(pairsIndex,4),:,:,:));
                    RatiosTitles{pairsIndex} = sprintf(['Ratio: ',MoleculeData2.MoleculeName,' I%d/',MoleculeData2.MoleculeName, ' I%d'], [LevelPairs(pairsIndex,3),LevelPairs(pairsIndex,4)]);
                elseif (LevelPairs(pairsIndex,1)~=0 && LevelPairs(pairsIndex,4)~=0)
                    Ratios(:,:,:,pairsIndex) = squeeze(Intensities1(LevelPairs(pairsIndex,1),:,:,:)./Intensities2(LevelPairs(pairsIndex,4),:,:,:));
                    RatiosTitles{pairsIndex} = sprintf(['Ratio: ',MoleculeData1.MoleculeName,' I%d/',MoleculeData2.MoleculeName, ' I%d'], [LevelPairs(pairsIndex,1),LevelPairs(pairsIndex,4)]);
                elseif (LevelPairs(pairsIndex,2)~=0 && LevelPairs(pairsIndex,3)~=0)
                    Ratios(:,:,:,pairsIndex) = squeeze(Intensities2(LevelPairs(pairsIndex,3),:,:,:)./Intensities1(LevelPairs(pairsIndex,2),:,:,:));
                    RatiosTitles{pairsIndex} = sprintf(['Ratio: ',MoleculeData2.MoleculeName,' I%d/',MoleculeData1.MoleculeName, ' I%d'], [LevelPairs(pairsIndex,3),LevelPairs(pairsIndex,2)]);
                end
            end
            
            %only one of the three:dvdrKmParsecs, Densities, Temperatures,
            %should contain one element
            if (~Scripts.onlyOneIsSingle(originalRequest1.VelocityDerivative, originalRequest1.CollisionPartnerDensities, originalRequest1.Temperature))
                ME = MException('DrawContours:InputArgumentError','Error in input. One of the following should be constant: dvdrKmParsecs, Densities, Temperatures');
                throw(ME);
            end
            
            [x,y,xName,yName,titleName] = Scripts.contourParameters (originalRequest1.Temperature, originalRequest1.CollisionPartnerDensities, originalRequest1.VelocityDerivative/Constants.dVdRConversionFactor);
            
            y = originalRequest1.CollisionPartnerDensities;
            x = 10^5 * originalRequest1.MoleculeDensity(1) ./ originalRequest1.VelocityDerivative;
            xName = 'N_H_C_O_+ / dVdr';
            yName = 'n_H_2';
            
            figure;
            
            for i=1:size(Ratios,4)
                z = squeeze(Ratios(:,:,:,i));
                [C,h] = contour3 (x, y, z, ContourLevels{i}, Scripts.lineStyleChooser(i)); hold all;
                set(gca,'XScale','log');
                hGroup = hggroup;
                set(h,'Parent',hGroup);
                set(get(get(hGroup,'Annotation'),'LegendInformation'),'IconDisplayStyle','on');
                set(hGroup,'DisplayName', RatiosTitles{i});
                if (numel(ContourLevels{i})>1); clabel(C,h,'Rotation',0); end;
            end
            
            hold off;figure(gcf);
            
            xlabel(xName);
            ylabel(yName);
            
            title(titleName);
            legend('toggle');
            %
            set(gca, 'YScale', 'log');
            
        end
        
        
    end
    
    methods (Access=public, Static=true)
        
        function [xName,yName] = contourParameters (XAxisProperty, YAxisProperty, PopulationRequest)
            
            xName = Scripts.buildAxisTitle(XAxisProperty, PopulationRequest);
            yName = Scripts.buildAxisTitle(YAxisProperty, PopulationRequest);

        end
        
        function [AxisName] = buildAxisTitle (AxisProperty, PopulationRequest)
            
            switch AxisProperty
                case LVGParameterCodes.Temperature
                    AxisName = 'Temperatures [K]';
                case LVGParameterCodes.CollisionPartnerDensity
                    AxisName = 'n_p_a_r_t_n_e_r_s [cm^-^3]';
                case LVGParameterCodes.VelocityDerivative
                    AxisName = sprintf('dv/dr [%s]', VelocityDerivativeUnits.GetHelpDescription(PopulationRequest.VelocityDerivativeUnits));
                case LVGParameterCodes.MoleculeAbundanceRatio
                    AxisName = 'X_m_o_l_e_c_u_l_e';
                case LVGParameterCodes.ConstantNpartnerBydVdR
                    AxisName = 'N_p_a_r_t_n_e_r/dv [cm^-^3 s]';
                otherwise
                    ME = MException('VerifyInput:unknownLVGParameterCode','Error in input. LVG Parameter Code [%d] is unknown', AxisProperty);
                    throw(ME);
            end
            
        end
        
        function [AxisData] = buildAxisData (PopulationRequest, AxisProperty)
            
            switch AxisProperty
                case LVGParameterCodes.Temperature
                    AxisData = PopulationRequest.Temperature;
                case LVGParameterCodes.CollisionPartnerDensity
                    AxisData = PopulationRequest.CollisionPartnerDensities;
                case LVGParameterCodes.VelocityDerivative
                    AxisData = PopulationRequest.VelocityDerivative;
                case LVGParameterCodes.MoleculeAbundanceRatio
                    AxisData = PopulationRequest.MoleculeAbundanceRatios;
                case LVGParameterCodes.ConstantNpartnerBydVdR
                    AxisData = PopulationRequest.ConstantNpartnerBydVdR;
                otherwise
                    ME = MException('VerifyInput:unknownLVGParameterCode','Error in input. LVG Parameter Code [%d] is unknown', AxisProperty);
                    throw(ME);
            end
            
        end

        
        function [Data, XAxis, YAxis, YRange, YAxisLog] = buildResultDisplayData(DrawType, PopulationResult)
            switch DrawType
                case ComparisonTypeCodes.IntegratedIntensity
                    Data = PopulationResult.IntegratedIntensity;
                    XAxis = 'J_u_p_p_e_r';
                    YAxis = 'I_J [erg cm^-^2 s^-^1 sr^-^1]';
                    YRange = [];
                    YAxisLog = true;
                case ComparisonTypeCodes.Beta
                    Data = PopulationResult.FinalBetaCoefficients;
                    XAxis = 'J_u_p_p_e_r';
                    YAxis = 'Beta';
                    YRange = [];
                    YAxisLog = true;
                case ComparisonTypeCodes.Tau
                    Data = PopulationResult.FinalTauCoefficients;
                    XAxis = 'J_u_p_p_e_r';
                    YAxis = 'Tau';
                    YRange = [];
                    YAxisLog = true;
                case ComparisonTypeCodes.Population
                    Data = PopulationResult.Population;
                    XAxis = 'J';
                    YAxis = 'x - Fractional population';
                    YRange = [0 1];
                    YAxisLog = false;
                otherwise
                    error('DrawType must be of type ComparisonTypeCodes');
            end
        end
        
        function LineStyle = lineStyleChooser(index)
            if (mod(index,4)==1)
                LineStyle = '-';
            elseif (mod(index,4)==2)
                LineStyle = '--';
            elseif (mod(index,4)==3)
                LineStyle = ':';
            else
                LineStyle = '-.';
            end
        end
        
        function Result = onlyOneIsSingle (varargin)
            
            singles = 0;
            
            for i=1:nargin
                singles = singles + numel(varargin{i})==1;
            end
            
            Result = singles == 1;
        end
        
        function TitleName = buildSEDTitleName (VelocityDerivatives, VelocityDerivativeUnit, Temperatures, CollisionPartnerDensities, MoleculeAbundanceRatios, ColumnDensities)
            
            dvdrDisplay = '';
            tempDisplay = '';
            colPartnerDensityDisplay = '';
            molDensityDisplay = '';
            colDensityDisplay = '';
            
            if (numel(CollisionPartnerDensities)==1)
                colPartnerDensityDisplay = sprintf('n_p_a_r_t_n_e_r_s=%g[cm^-^3]', CollisionPartnerDensities);
            end
            if (numel(Temperatures)==1)
                tempDisplay = sprintf('T=%d[K]', Temperatures);
            end
            if (numel(VelocityDerivatives)==1)
                dvdrDisplay = sprintf('dv/dr=%g[%s]', VelocityDerivatives, VelocityDerivativeUnits.GetHelpDescription(VelocityDerivativeUnit));
            end
            if (numel(MoleculeAbundanceRatios)==1)
                molDensityDisplay = sprintf('X_m_o_l_e_c_u_l_e=%g', MoleculeAbundanceRatios);
            end
            if (numel(ColumnDensities)==1)
                colDensityDisplay = sprintf('N_c_o_l_u_m_n=%g[cm^-^2]', ColumnDensities);
            end
            
            TitleName = FileIOHelper.ConcatWithSeperator({colPartnerDensityDisplay tempDisplay dvdrDisplay molDensityDisplay colDensityDisplay}, ',');
            
        end
        
        function DisplayName = buildSEDDisplayName (VelocityDerivatives, VelocityDerivativeIndex, VelocityDerivativeUnit,...
                Temperatures, TemperatureIndex, CollisionPartnerDensities, CollisionPartnerDensityIndex,...
                MoleculeAbundanceRatios, MoleculeAbundanceRatiosIndex, ColumnDensities, ColumnDensityIndex)
            
            dvdrDisplay = '';
            tempDisplay = '';
            colPartnerDensityDisplay = '';
            molDensityDisplay = '';
            colDensityDisplay = '';
            
            if (numel(CollisionPartnerDensities)>1)
                colPartnerDensityDisplay = sprintf('n_p_a_r_t_n_e_r_s=%g[cm^-^3]', CollisionPartnerDensities(CollisionPartnerDensityIndex));
            end
            if (numel(Temperatures)>1)
                tempDisplay = sprintf('T=%d[K]', Temperatures(TemperatureIndex));
            end
            if (numel(VelocityDerivatives)>1)
                dvdrDisplay = sprintf('dv/dr=%g[%s]', VelocityDerivatives(VelocityDerivativeIndex), VelocityDerivativeUnits.GetHelpDescription(VelocityDerivativeUnit));
            end
            if (numel(MoleculeAbundanceRatios)>1)
                molDensityDisplay = sprintf('X_m_o_l_e_c_u_l_e=%g', MoleculeAbundanceRatios(MoleculeAbundanceRatiosIndex));
            end
            if (numel(ColumnDensities)>1)
                colDensityDisplay = sprintf('N_c_o_l_u_m_n=%g[cm^-^2]', ColumnDensities(ColumnDensityIndex));
            end
            
            DisplayName = FileIOHelper.ConcatWithSeperator({colPartnerDensityDisplay tempDisplay dvdrDisplay molDensityDisplay colDensityDisplay}, ',');
            
        end
        
    end
    
end
