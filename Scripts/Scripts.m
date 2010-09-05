classdef Scripts
    
    methods (Access=public, Static=true)
        
        function DrawContours1Molecule(PopulationResult, LevelPairs, ContourLevels)
            %Temperatures, Densities, dvdrKmParsecs, LevelPairs, ContourLevels, Intensities, MoleculeData)
            originalRequest = PopulationResult.OriginalRequest;
            MoleculeData = WorkspaceHelper.GetMoleculeDataFromWorkspace(originalRequest.MoleculeFileName);            
            
            %only one of the three:dvdrKmParsecs, Densities, Temperatures,
            %should contain one element
            if (Scripts.onlyOneIsSingle(originalRequest.VelocityDerivative, originalRequest.CollisionPartnerDensities, originalRequest.Temperature))
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
        
        function DrawMax1Molecule(PopulationResult, ContourLevels)
            %Temperatures, Densities, dvdrKmParsecs, LevelPairs, ContourLevels, Intensities, MoleculeData)
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
        
        function DrawContours2Molecules(Temperatures, Densities, dvdrKmParsecs, LevelPairs, ContourLevels, Intensities1, MoleculeData1, Intensities2, MoleculeData2)
            
            %only one of the three:dvdrKmParsecs, Densities, Temperatures,
            %should contain one element
            if (Scripts.onlyOneIsSingle(dvdrKmParsecs, Densities, Temperatures))
                ME = MException('DrawContours:InputArgumentError','Error in input. One of the following should be constant: dvdrKmParsecs, Densities, Temperatures');
                throw(ME);
            end
            
            [x,y,xName,yName,titleName] = Scripts.contourParameters (Temperatures, Densities, dvdrKmParsecs/Constants.dVdRConversionFactor);
            
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
            
            figure;
            
            for i=1:size(Ratios,4)
                [C,h] = contour3 (x, y, squeeze(Ratios(:,:,:,i)), ContourLevels{i}, Scripts.lineStyleChooser(i)); hold all;
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
            
            title(strcat('Radex - ',titleName));
            legend('toggle');
            %
            set(gca, 'YScale', 'log');
            set(gca,'YTick',[25 50 100 200 400]);
            
            
        end
                       
        function Intensities = DrawSEDLVG (dvdrKmParsec, Densities, Temperatures, ColumnDensities, CollisionPartnerMoleculeDensityRatio, MoleculeData, CollisionPartnerRates, Weights, BetaProvider)
            
            LVGSolverSlow = LevelPopulationSolverLVGSlowAccurate(MoleculeData, BetaProvider, 1000);
            
            Intensities = zeros(MoleculeData.MolecularLevels, numel(Temperatures), numel(Densities), numel(ColumnDensities));
            
            IntensitiesClc = IntensitiesCalculator(MoleculeData);
            
            tic;
            
            for tempIndex=1:numel(Temperatures)
                
                [ Population, Beta, converged, iterations, diffHistory, popHistory, tauHistory, betaHistory] = LVGSolverSlow.SolveLevelsPopulation(CollisionPartnerRates, Weights, Temperatures(tempIndex), Densities*CollisionPartnerMoleculeDensityRatio, dvdrKmParsec*Constants.dVdRConversionFactor, Densities);
                
                for densityIndex=1:numel(Densities)
                    
                    if converged(densityIndex) == true
                        
                        Intensities(:,tempIndex,densityIndex,:) = IntensitiesClc.CalculateIntensitiesLVG(Population(:,densityIndex),Beta(:,densityIndex),ColumnDensities);
                        
                    end
                    
                end
                
            end
            
            toc;
            
            Scripts.drawSED(Intensities, Densities, Temperatures, ColumnDensities)
            
        end
        
        function Intensities = DrawSEDLTE (Densities, Temperatures, ColumnDensities, MoleculeData, CollisionPartnerRates, Weights)
            
            LTESolver = LevelPopulationSolverLTE(MoleculeData);
            IntensitiesClc = IntensitiesCalculator(MoleculeData);
            
            Intensities = zeros(MoleculeData.MolecularLevels, numel(Temperatures), numel(Densities), numel(ColumnDensities));
            
            for tempIndex=1:numel(Temperatures)
                
                Population = LTESolver.SolveLevelsPopulation(CollisionPartnerRates, Weights, Temperatures(tempIndex), Densities);
                
                for densityIndex=1:numel(Densities)
                    
                    Intensities(:,tempIndex,densityIndex,:) = IntensitiesClc.CalculateIntensitiesLVG(Population(:,densityIndex),ones(size(Population(:,densityIndex))), ColumnDensities);
                    
                end
                
            end
            
            Scripts.drawSED(Intensities, Densities, Temperatures, ColumnDensities)
            
        end
        
        function Intensities = DrawSEDOpticallyThin (Densities, Temperatures, ColumnDensities, MoleculeData, CollisionPartnerRates, Weights)
            
            OthinSolver = LevelPopulationSolverOpticallyThin(MoleculeData);
            IntensitiesClc = IntensitiesCalculator(MoleculeData);
            
            Intensities = zeros(MoleculeData.MolecularLevels, numel(Temperatures), numel(Densities), numel(ColumnDensities));
            
            for tempIndex=1:numel(Temperatures)
                
                Population = OthinSolver.SolveLevelsPopulation(CollisionPartnerRates, Weights, Temperatures(tempIndex), Densities);
                
                for densityIndex=1:numel(Densities)
                    
                    Intensities(:,tempIndex,densityIndex,:) = IntensitiesClc.CalculateIntensitiesLVG(Population(:,densityIndex),ones(size(Population(:,densityIndex))), ColumnDensities);
                    
                end
                
            end
            
            Scripts.drawSED(Intensities, Densities, Temperatures, ColumnDensities)
            
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
        
        function DrawBoltzmannFitOpticallyThin (Density, Temperature, MoleculeData, CollisionPartnerRates, Weights)
            
            OthinSolver = LevelPopulationSolverOpticallyThin(MoleculeData);
            
            Population = OthinSolver.SolveLevelsPopulation(CollisionPartnerRates, Weights, Temperature, Density);

            Scripts.drawBoltzmannFit(Density, Temperature, Population, MoleculeData, CollisionPartnerRates, Weights);
            
        end

        function DrawBoltzmannFitLVG (dvdrKmParsec, Density, Temperature, CollisionPartnerMoleculeDensityRatio, MoleculeData, CollisionPartnerRates, Weights, BetaProvider)
             
            LVGSolverSlow = LevelPopulationSolverLVGSlowAccurate(MoleculeData, BetaProvider, 1000);
            
            [ Population, Beta, converged, iterations, diffHistory, popHistory, tauHistory, betaHistory] = LVGSolverSlow.SolveLevelsPopulation(CollisionPartnerRates, Weights, Temperature, Density*CollisionPartnerMoleculeDensityRatio, dvdrKmParsec*Constants.dVdRConversionFactor, Density);

            Scripts.drawBoltzmannFit(Density, Temperature, Population, MoleculeData, CollisionPartnerRates, Weights);
            
        end
        
        function DrawCollisionRateCoefficients(Temperature, CollisionRates, NumContourLevels)
           
            rates = CollisionRates.CollisionRateCoefficientMatrix(Temperature);
            
            contour3(rates,NumContourLevels); figure(gcf)
            
            xlabel('Final Level');
            ylabel('Initial Level');
            zlabel('q [cm^3 s^-^1]');
            
            title(sprintf('Collision Rate Coefficients. T=%dK', Temperature));
            
        end
     
        function CompareWithRadex (RadexPop, OurPopulation, CollisionPartnerDensity, Temperature, dvdrKmParsecs, FileName)
        
            maxSize = max([numel(RadexPop) numel(OurPopulation)]);
            
            if (numel(RadexPop) < maxSize)
                RadexPop = cat(1, RadexPop, zeros(maxSize - numel(RadexPop),1));
            end
            
            if (numel(OurPopulation) < maxSize)
                OurPopulation = cat(1, OurPopulation, zeros(maxSize - numel(OurPopulation)));
            end                
                  
            xValues = 0:(maxSize-1);
            
            plot(xValues, OurPopulation, 'DisplayName', 'Our'); hold all;
            h = plot(xValues, RadexPop, 'DisplayName', 'Radex'); %hold all;
            
                             
            hold off;
            figure(gcf);
            
            xlabel('J');
            ylabel('x - Fractional population');
            
            titleName = Scripts.buildSEDTitleName(CollisionPartnerDensity, Temperature, [], dvdrKmParsecs/Constants.dVdRConversionFactor);
            title(titleName);
            axis([0 maxSize-1 0 1]);
            
            ticks = get(gca,'XTick');
            if any(~(floor(ticks)==ticks))
                set(gca,'XTick',xValues)
            end
            
            legend('toggle');
            
            if nargin > 5 && ~isempty(FileName)
               saveas (h,FileName);
            end
        end

        function CompareWithPACS (Pacs, OurPopulation, CollisionPartnerDensity, Temperature, dvdrKmParsecs, FileName)
        
            maxSize = max([numel(Pacs) numel(OurPopulation)]);
            
            if (numel(Pacs) < maxSize)
                Pacs = cat(1, Pacs, zeros(maxSize - numel(Pacs),1));
            end
            
            if (numel(OurPopulation) < maxSize)
                OurPopulation = cat(1, OurPopulation, zeros(maxSize - numel(OurPopulation)));
            end                
                  
            xValues = 0:(maxSize-1);
            
            plot(xValues, OurPopulation, '--', 'DisplayName', 'LVG Model - '); hold all;
            h = plot(xValues, Pacs, 'xk', ...
                'LineWidth',2,...
                'MarkerSize',10,...
                'DisplayName', 'PACS NGC1068'); %hold all;
                             
            hold off;
            figure(gcf);
            
            xlabel('J_U_p_p_e_r');
            %ylabel('x - Fractional population');
            ylabel('Intensity [W m^-^2]');
            
            titleName = Scripts.buildSEDTitleName(CollisionPartnerDensity, Temperature, [], dvdrKmParsecs/Constants.dVdRConversionFactor);
            title(titleName);
            %axis([0 maxSize-1 0 1]);
            %set(gca,'XTick',xValues)
            
            legend('toggle');
            
            if nargin > 5 && ~isempty(FileName)
               saveas (h,FileName);
            end
        end
        
        
        function DrawPopulation (Population, Densities, Temperatures)
            
            xValues = 0:(size(Population,1)-1);
            
            for tempIndex=1:numel(Temperatures)
                for densityIndex=1:numel(Densities)

                    displayName = Scripts.buildSEDDisplayName(Densities, densityIndex, Temperatures, tempIndex, [], 0);
                    plot(xValues, Population(:,tempIndex,densityIndex), 'DisplayName', displayName); hold all;                    
                    
                end
            end
            
            hold off;
            figure(gcf);
            
            xlabel('J');
            ylabel('x - Fractional population');
            
            titleName = Scripts.buildSEDTitleName(Densities, Temperatures, [],[]);
            title(titleName);
            
            legend('toggle');
            
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
        
    end
    
    methods (Access=private, Static=true)
        
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
        
        function CalculatedTemp = drawBoltzmannFit (Density, Temperature, Population, MoleculeData, CollisionPartnerRates, Weights)
            
            LTESolver = LevelPopulationSolverLTE(MoleculeData);
            LTEPopulation = LTESolver.SolveLevelsPopulation(CollisionPartnerRates, Weights, Temperature, Density);
            
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
            
            plot(energies, logRatio, 'DisplayName', 'LogRatio vs Energies'); 
            hold all;
            plot(energies, LTElogRatio, 'DisplayName', 'LTE Reference'); 
            hold off; figure(gcf);
            
            fitTitle = sprintf('. Fitted Temperature=%gK', CalculatedTemp);
            
            titleName = Scripts.buildSEDTitleName(Density, Temperature, [ ]);
            
            titleName = strcat(titleName, fitTitle);
            title(titleName);
            
            xlabel('Energies [erg]');
            ylabel('log[X_j/(X_0*G_j)]');
            
            legend('toggle');
            
        end
                
        function drawSED (Intensities, Densities, Temperatures, ColumnDensities)
            
            xValues = 0:(size(Intensities,1)-1);
            
            for tempIndex=1:numel(Temperatures)
                for densityIndex=1:numel(Densities)
                    for columnDensityIndex=1:numel(ColumnDensities)
                        
                        displayName = Scripts.buildSEDDisplayName(Densities, densityIndex, Temperatures, tempIndex, ColumnDensities, columnDensityIndex);
                        semilogy(xValues, Intensities(:,tempIndex,densityIndex,columnDensityIndex), 'DisplayName', displayName); hold all;
                        
                    end
                end
            end
            
            hold off;
            figure(gcf);
            
            xlabel('J');
            ylabel('I_J [erg^-^1 sr^-^1 molecule^-^1]');
            
            titleName = Scripts.buildSEDTitleName(Densities, Temperatures, ColumnDensities);
            title(titleName);
            
            legend('toggle');
            
        end
        
        function TitleName = buildSEDTitleName (CollisionPartnerDensities, Temperatures, ColumnDensities, dvdrKmParsecs)
            
            densityDisplay = '';
            tempDisplay = '';
            colDensityDisplay = '';
            dvdrKmParsecsDisplay = '';
            
            if (numel(CollisionPartnerDensities)==1)
                densityDisplay = sprintf('n=%g[cm^-^3]', CollisionPartnerDensities(1));
            end
            
            if (numel(Temperatures)==1)
                tempDisplay = sprintf('T=%d[K]', Temperatures(1));
            end
            
            if (numel(ColumnDensities)==1)
                colDensityDisplay = sprintf('ColumnDensity=%g[cm^-^2]', ColumnDensities(1));
            end
            
            if (numel(dvdrKmParsecs)==1)
                dvdrKmParsecsDisplay = sprintf('dv/dr=%g[km s^-^1 pc^-^1]', dvdrKmParsecs(1));
            end
            
            TitleName = FileIOHelper.ConcatWithSeperator({densityDisplay tempDisplay colDensityDisplay dvdrKmParsecsDisplay}, ',');
            
        end
        
        function DisplayName = buildSEDDisplayName (Densities, DensityIndex, Temperatures, TempIndex, ColumnDensities, ColumnDensityIndex)
            
            densityDisplay = '';
            tempDisplay = '';
            colDensityDisplay = '';
            
            if (numel(Densities)>1)
                densityDisplay = sprintf('n=%gcm^-^3', Densities(DensityIndex));
            end
            
            if (numel(Temperatures)>1)
                tempDisplay = sprintf('T=%dK', Temperatures(TempIndex));
            end
            
            if (numel(ColumnDensities)>1)
                colDensityDisplay = sprintf('ColumnDensity=%gcm^-^2', ColumnDensities(ColumnDensityIndex));
            end
            
            DisplayName = FileIOHelper.ConcatWithSeperator({densityDisplay tempDisplay colDensityDisplay}, ',');
            
        end
                
    end
    
end