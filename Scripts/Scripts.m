classdef Scripts
    
    methods (Access=public, Static=true)
        
        function [Ratios, RatiosTitles] = CalculateIntensityRatios(PopulationResultPairs, LevelPairs)
            
            if size(PopulationResultPairs,2)~=2 || size(LevelPairs,2)~=2
                ME = MException('CalculateIntensityRatios:InputArgumentError','Error in input. Input matrices should contain two columns');
                throw(ME);
            elseif size(PopulationResultPairs,1)~=size(LevelPairs,1)
                ME = MException('CalculateIntensityRatios:InputArgumentError','Error in input. PopulationResultPairs and LevelPairs should conatin the same number of rows');
                throw(ME);
            end
            
            for i=1:size(PopulationResultPairs,1)
                if ~LVGSolverPopulationRequest.EqualParameterSpace(PopulationResultPairs(i,1).OriginalRequest,PopulationResultPairs(i,2).OriginalRequest)
                    ME = MException('CalculateIntensityRatios:InputArgumentError','Error in input. All results in PopulationResultArray should be on the same parameter space. Problematic pair index: %g', i);
                    throw(ME);
                end
            end
            
            dummyIntensity = PopulationResultPairs(1).Intensities;
            Ratios = zeros(size(dummyIntensity,2),size(dummyIntensity,3),size(dummyIntensity,4),size(LevelPairs,1));
            RatiosTitles = cell(1,size(LevelPairs,1));
            
            for pairsIndex=1:size(LevelPairs,1)
                
                UpperIntensity = PopulationResultPairs(pairsIndex,1).Intensities;
                LowerIntensity = PopulationResultPairs(pairsIndex,2).Intensities;
                
                UpperMolecule = WorkspaceHelper.GetMoleculeDataFromWorkspace(PopulationResultPairs(pairsIndex,1).OriginalRequest.MoleculeFileName);
                LowerMolecule = WorkspaceHelper.GetMoleculeDataFromWorkspace(PopulationResultPairs(pairsIndex,2).OriginalRequest.MoleculeFileName);
                
                UpperIntensityLevelIndex = LevelPairs(pairsIndex,1);
                LowerIntensityLevelIndex = LevelPairs(pairsIndex,2);
                
                Ratios(:,:,:,pairsIndex) = squeeze(UpperIntensity(UpperIntensityLevelIndex,:,:,:)./LowerIntensity(LowerIntensityLevelIndex,:,:,:));
                RatiosTitles{pairsIndex} = sprintf('Ratio: %s J(%d-%d)/ %s J(%d-%d)', UpperMolecule.MoleculeName, UpperIntensityLevelIndex-1, UpperIntensityLevelIndex-2,...
                    LowerMolecule.MoleculeName, LowerIntensityLevelIndex-1,LowerIntensityLevelIndex-2);
                
            end
            
        end
        
        function DrawContours(Data, DataTitles, ContourLevels, VelocityDerivative, CollisionPartnerDensities, Temperature, varargin)
            
            [x,y,xName,yName,titleName] = Scripts.contourParameters (Temperature, CollisionPartnerDensities, VelocityDerivative/Constants.dVdRConversionFactor);
            
            p = inputParser;   % Create instance of inputParser class.
            p.addParamValue('x', x, @isnumeric);
            p.addParamValue('xName', xName, @ischar);
            p.addParamValue('y', y, @isnumeric);
            p.addParamValue('yName', yName, @ischar);
            p.addParamValue('titleName', titleName, @ischar);
            p.addParamValue('XScale', 'log', @(x)any(strcmpi(x,{'log','linear'})));
            p.addParamValue('YScale', 'log', @(x)any(strcmpi(x,{'log','linear'})));
            p.parse(varargin{:});
            
            %only one of the three:dvdrKmParsecs, Densities, Temperatures,
            %should contain one element
            if (~Scripts.onlyOneIsSingle(VelocityDerivative, CollisionPartnerDensities, Temperature))
                ME = MException('DrawContours:InputArgumentError','Error in input. One of the following should be constant: dvdrKmParsecs, Densities, Temperatures');
                throw(ME);
            end
            
            figure;
            
            for i=1:size(Data,4)
                z = squeeze(Data(:,:,:,i));
                Levels = contourcs(z, ContourLevels{i});
                
                for j=1:numel(Levels)
                    
                    h = plot(Levels(j).X, Levels(j).Y, Scripts.lineStyleChooser(i));hold all;
                    %[C,h] = contour3 (p.Results.x, p.Results.y, z, ContourLevels{i}, Scripts.lineStyleChooser(i)); hold all;
                    hGroup = hggroup;
                    set(h,'Parent',hGroup);
                    set(get(get(hGroup,'Annotation'),'LegendInformation'),'IconDisplayStyle','on');
                    set(hGroup,'DisplayName', DataTitles{i});
                    %if (numel(ContourLevels{i})>1); clabel(C,h,'Rotation',0); end;
                    
                end
                
                
            end
            
            hold off;figure(gcf);
            
            set(gca,'XScale',p.Results.XScale);
            set(gca, 'YScale', p.Results.YScale);
            xlabel(p.Results.xName);
            ylabel(p.Results.yName);
            title(p.Results.titleName);
            legend('toggle');
            
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
            
        end
        
        function DrawCollisionRateCoefficients(Temperature, CollisionRates, NumContourLevels)
            
            rates = CollisionRates.CollisionRateCoefficientMatrix(Temperature);
            
            contour3(rates,NumContourLevels); figure(gcf)
            
            xlabel('Final Level');
            ylabel('Initial Level');
            zlabel('q [cm^3 s^-^1]');
            
            title(sprintf('Collision Rate Coefficients. T=%dK', Temperature));
            
        end
        
        function CompareResults (Data, PlotArguments, YLabel, XLabel, YRange, YAxisLog, Title, FileName)
            
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
            
            legend('toggle');
            
            if ~isempty(FileName)
                saveas (h,FileName);
            end
        end
        
        function DrawResults1Molecule (DrawType, PopulationResult, VelocityDerivativeIndices, TemperatureIndices, CollisionPartnerDensitiesIndices, FileName)
            
            p = inputParser;    % Create an instance of the class.
            p.addRequired('DrawType', @(x)isnumeric(x) && isscalar(x));
            p.addRequired('PopulationResult', @(x)isa(x,'LVGSolverPopulationResult'));
            p.addRequired('VelocityDerivativeIndices', @(x)isnumeric(x));
            p.addRequired('TemperatureIndices', @(x)isnumeric(x));
            p.addRequired('CollisionPartnerDensitiesIndices', @(x)isnumeric(x));                        
            p.addOptional('FileName', '', @ischar);
            p.parse(DrawType, PopulationResult, VelocityDerivativeIndices, TemperatureIndices, CollisionPartnerDensitiesIndices, FileName);
            
            switch DrawType
                case ComparisonTypeCodes.Intensities
                    Data = PopulationResult.Intensities;
                    xaxis = 'J_u_p_p_e_r';
                    yaxis = 'I_J [erg^-^1 sr^-^1 molecule^-^1]';
                    YRange = [];
                    YAxisLog = true;
                case ComparisonTypeCodes.Beta
                    Data = PopulationResult.FinalBetaCoefficients;
                    xaxis = 'J_u_p_p_e_r';
                    yaxis = 'Beta';
                    YRange = [];
                    YAxisLog = true;
                case ComparisonTypeCodes.Tau
                    Data = PopulationResult.FinalTauCoefficients;
                    xaxis = 'J_u_p_p_e_r';
                    yaxis = 'Tau';
                    YRange = [];
                    YAxisLog = true;
                case ComparisonTypeCodes.Population
                    Data = PopulationResult.Population;
                    xaxis = 'J';
                    yaxis = 'x - Fractional population';
                    YRange = [0 1];
                    YAxisLog = false;
                otherwise
                    error('DrawType must be of type ComparisonTypeCodes');
            end
            
            request = PopulationResult.OriginalRequest;
            
            RefinedData = cell(1,0);
            PlotArguments = cell(1,0);
            
            for tempIndex=1:numel(TemperatureIndices)
                for densityIndex=1:numel(CollisionPartnerDensitiesIndices)
                    for dvdrIndex=1:numel(VelocityDerivativeIndices)
                        
                        displayName = Scripts.buildSEDDisplayName(request.VelocityDerivative(VelocityDerivativeIndices), dvdrIndex, request.VelocityDerivativeUnits,...
                            request.Temperature(TemperatureIndices), tempIndex, request.CollisionPartnerDensities(CollisionPartnerDensitiesIndices), densityIndex, ...
                            request.MoleculeDensity(CollisionPartnerDensitiesIndices), densityIndex, request.CloudColumnDensity(CollisionPartnerDensitiesIndices), densityIndex);
                        
                        RefinedData{end+1} = Data(:,tempIndex,densityIndex,dvdrIndex);
                        PlotArguments{end+1} = {'DisplayName', displayName};
                        
                    end
                end
            end
           
            titleName = Scripts.buildSEDTitleName(request.VelocityDerivative(VelocityDerivativeIndices), request.VelocityDerivativeUnits,...
                request.Temperature(TemperatureIndices), request.CollisionPartnerDensities(CollisionPartnerDensitiesIndices), ...
                request.MoleculeDensity(CollisionPartnerDensitiesIndices), request.CloudColumnDensity(CollisionPartnerDensitiesIndices));

            Scripts.CompareResults(RefinedData, PlotArguments, yaxis, xaxis, YRange, YAxisLog, titleName, p.Results.FileName);
            
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
            
            [values,MaxIndices] =max(PopulationResult.Intensities);
            
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
            %Temperatures, Densities, dvdrKmParsecs, LevelPairs, ContourLevels, Intensities, MoleculeData)
            originalRequest = PopulationResult.OriginalRequest;
            MoleculeData = WorkspaceHelper.GetMoleculeDataFromWorkspace(originalRequest.MoleculeFileName);
            
            %only one of the three:dvdrKmParsecs, Densities, Temperatures,
            %should contain one element
            if (~Scripts.onlyOneIsSingle(originalRequest.VelocityDerivative, originalRequest.CollisionPartnerDensities, originalRequest.Temperature))
                ME = MException('DrawContours:InputArgumentError','Error in input. One of the following should be constant: dvdrKmParsecs, Densities, Temperatures');
                throw(ME);
            end
            
            [x,y,xName,yName,titleName] = Scripts.contourParameters (originalRequest.Temperature, originalRequest.CollisionPartnerDensities, originalRequest.VelocityDerivative/Constants.dVdRConversionFactor);
            
            Ratios = zeros(size(PopulationResult.Intensities,2),size(PopulationResult.Intensities,3),size(PopulationResult.Intensities,4),size(LevelPairs,1));
            RatiosTitles = cell(1,size(LevelPairs,1));
            
            for pairsIndex=1:size(LevelPairs,1)
                Ratios(:,:,:,pairsIndex) = squeeze(PopulationResult.Intensities(LevelPairs(pairsIndex,1),:,:,:)./PopulationResult.Intensities(LevelPairs(pairsIndex,2),:,:,:));
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
            
            Intensities1 = PopulationResult1.Intensities;
            Intensities2 = PopulationResult2.Intensities;
            originalRequest1 = PopulationResult1.OriginalRequest;
            originalRequest2 = PopulationResult2.OriginalRequest;
            MoleculeData1 = WorkspaceHelper.GetMoleculeDataFromWorkspace(originalRequest1.MoleculeFileName);
            MoleculeData2 = WorkspaceHelper.GetMoleculeDataFromWorkspace(originalRequest2.MoleculeFileName);
            
            Ratios = zeros(size(Intensities1,2),size(Intensities1,3),size(Intensities1,4),size(LevelPairs,1));
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
        
        function [x,y,xName,yName,titleName] = contourParameters (Temperatures, Densities, dvdrKmParsecs)
            if (numel(dvdrKmParsecs)==1)
                x = Densities;
                y = Temperatures;
                xName = 'Densities [cm^-^3]';
                yName = 'Temperatures [K]';
                titleName = sprintf('dv/dr=%g[km s^-^1 pc^-^1]', dvdrKmParsecs(1));
            elseif (numel(Densities)==1)
                x = dvdrKmParsecs;
                y = Temperatures;
                xName = 'dv/dr [km s^-^1 pc^-^1]';
                yName = 'Temperatures [K]';
                titleName = sprintf('Density=%g[cm^-^3]', Densities(1));
            elseif (numel(Temperatures)==1)
                x = dvdrKmParsecs;
                y = Densities;
                xName = 'dv/dr [km s^-^1 pc^-^1]';
                yName = 'Densities [cm^-^3]';
                titleName = sprintf('T=%dK',Temperatures(1));
            else
                ME = MException('DrawContours:InputArgumentError','Error in input. One of the following should be constant: dvdrKmParsecs, Densities, Temperatures');
                throw(ME);
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
        
        function TitleName = buildSEDTitleName (VelocityDerivatives, VelocityDerivativeUnit, Temperatures, CollisionPartnerDensities, MoleculeDensities, ColumnDensities)
            
            dvdrDisplay = '';
            tempDisplay = '';
            colPartnerDensityDisplay = '';
            molDensityDisplay = '';
            colDensityDisplay = '';
            
            if (numel(CollisionPartnerDensities)==1)
                colPartnerDensityDisplay = sprintf('N_P_a_r_t_n_e_r_s=%g[cm^-^3]', CollisionPartnerDensities);
            end
            if (numel(Temperatures)==1)
                tempDisplay = sprintf('T=%d[K]', Temperatures);
            end
            if (numel(VelocityDerivatives)==1)
                dvdrDisplay = sprintf('dv/dr=%g[%s]', VelocityDerivatives, VelocityDerivativeUnits.GetHelpDescription(VelocityDerivativeUnit));
            end
            if (numel(MoleculeDensities)==1)
                molDensityDisplay = sprintf('N_M_o_l=%g[cm^-^2]', MoleculeDensities);
            end
            if (numel(ColumnDensities)==1)
                colDensityDisplay = sprintf('N_C_o_l_u_m_n=%g[cm^-^2]', ColumnDensities);
            end
            
            TitleName = FileIOHelper.ConcatWithSeperator({colPartnerDensityDisplay tempDisplay dvdrDisplay molDensityDisplay colDensityDisplay}, ',');
            
        end
        
        function DisplayName = buildSEDDisplayName (VelocityDerivatives, VelocityDerivativeIndex, VelocityDerivativeUnit,...
                Temperatures, TemperatureIndex, CollisionPartnerDensities, CollisionPartnerDensityIndex,...
                MoleculeDensities, MoleculeDensityIndex, ColumnDensities, ColumnDensityIndex)
            
            dvdrDisplay = '';
            tempDisplay = '';
            colPartnerDensityDisplay = '';
            molDensityDisplay = '';
            colDensityDisplay = '';
            
            if (numel(CollisionPartnerDensities)>1)
                colPartnerDensityDisplay = sprintf('N_P_a_r_t_n_e_r_s=%g[cm^-^3]', CollisionPartnerDensities(CollisionPartnerDensityIndex));
            end
            if (numel(Temperatures)>1)
                tempDisplay = sprintf('T=%d[K]', Temperatures(TemperatureIndex));
            end
            if (numel(VelocityDerivatives)>1)
                dvdrDisplay = sprintf('dv/dr=%g[%s]', VelocityDerivatives(VelocityDerivativeIndex), VelocityDerivativeUnits.GetHelpDescription(VelocityDerivativeUnit));
            end
            if (numel(MoleculeDensities)>1)
                molDensityDisplay = sprintf('N_M_o_l=%g[cm^-^2]', MoleculeDensities(MoleculeDensityIndex));
            end
            if (numel(ColumnDensities)>1)
                colDensityDisplay = sprintf('N_C_o_l_u_m_n=%g[cm^-^2]', ColumnDensities(ColumnDensityIndex));
            end
            
            DisplayName = FileIOHelper.ConcatWithSeperator({colPartnerDensityDisplay tempDisplay dvdrDisplay molDensityDisplay colDensityDisplay}, ',');
            
        end
        
    end
    
end