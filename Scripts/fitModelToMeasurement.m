function fitModelToMeasurement()

Result = WorkspaceHelper.GetLVGResultFromWorkspace('PACS LVG');
Measurement = evalin('base', 'PacsLow');
PercentError = evalin('base', 'ErrorLow');

dvdrKmParsecIndices = 1:numel(Result.OriginalRequest.VelocityDerivative);
%temperatureIndices = 1:numel(Result.OriginalRequest.Temperature);
temperatureIndices = 1:find(Result.OriginalRequest.Temperature==100);
densityIndices = 1:numel(Result.OriginalRequest.CollisionPartnerDensities);
%densityIndices = find(Result.OriginalRequest.CollisionPartnerDensities==3e5);
moleculeAbundanceIndices = 1:numel(Result.OriginalRequest.MoleculeAbundanceRatios);

SaveImages = 1;
GenerateReport = 1;
ShowUpperAndLowerBounds = 0;

YLabel = 'Intensity [W m^-^2]';
XLabel = '';

YRange = [1e-18 1e-15];

%%%%%

figure;

request = Result.OriginalRequest;

if SaveImages
    picsPath = FileIOHelper.ComparisonPicsOutputPath();
    [status, message, messageid] = rmdir(picsPath, 's');
    mkdir(picsPath);
end

chiSquareGrid = zeros(numel(temperatureIndices),numel(densityIndices));

for dvdrKmParsecIndex = dvdrKmParsecIndices
    for tempIndex = temperatureIndices
        for molAbundanceIndex=moleculeAbundanceIndices
            for densityIndex = densityIndices
                
                %Compare results using a graph
                if SaveImages
                    %picFileName = sprintf('Temperature%g_%g.jpg',tempIndex, find(dvdrKmParsecArray==dvdrKmParsecIndex));
                    picFileName = sprintf('Temperature%g_%g.jpg',request.Temperature(tempIndex), densityIndex);
                    FileName = fullfile(picsPath, picFileName);
                else
                    FileName = '';
                end
                
                %normalize results.
                ourCmp = Result.Intensities(:,tempIndex,densityIndex,dvdrKmParsecIndex);
                rawColumnDensityFactor = 1.2e-16/max(ourCmp);
                ourCmp = ourCmp*rawColumnDensityFactor;
                
%                 [val, ind] = max(Measurement);
%                 ourCmp = Result.Intensities(:,tempIndex,densityIndex,dvdrKmParsecIndex);
%                 rawColumnDensityFactor = Measurement(ind)/max(ourCmp);
%                 ourCmp = ourCmp*rawColumnDensityFactor;
                
                mass = (1e3 * rawColumnDensityFactor) * (1.67e-24) * Constants.pi * (14.4 * 3.14e24)^2 * (8e-5)^-1;
                solarMass = mass / (1.98892 * 10^33);
                
                if ~ShowUpperAndLowerBounds
                    data = cell(1,2);
                    data{1} = ourCmp;
                    data{2} = Measurement;
                    plotArguments = cell(1,2);
                    plotArguments{1} = {'--', 'DisplayName', 'LVG Model'};
                    plotArguments{2} = {'xk', 'LineWidth',2, 'MarkerSize',10, 'DisplayName', 'Measurement'};
                else
                    data = cell(1,2);
                    data{1} = ourCmp;
                    data{2} = Measurement + Measurement.*PercentError/100;
                    data{3} = Measurement - Measurement.*PercentError/100;
                    plotArguments = cell(1,2);
                    plotArguments{1} = {'--', 'DisplayName', 'LVG Model'};
                    plotArguments{2} = {'-', 'DisplayName', 'Measurement - Upper Limit'};
                    plotArguments{3} = {'-', 'DisplayName', 'Measurement - Lower Limit'};
                end
                
                if isempty(XLabel); XLabel = ('J_u_p_p_e_r'); end
                if isempty(YLabel); YLabel = ('I_J [erg^-^1 sr^-^1 molecule^-^1]'); end
                
                titleName = Scripts.buildSEDTitleName(request.VelocityDerivative(dvdrKmParsecIndex), request.VelocityDerivativeUnits, request.Temperature(tempIndex),...
                    request.CollisionPartnerDensities(densityIndex), request.MoleculeAbundanceRatios(molAbundanceIndex), solarMass);
                
                %Data, PlotArguments, YLabel, XLabel, YRange, YAxisLog, Title, FileName
                Scripts.CompareResults(data, plotArguments, XLabel, YLabel, YRange, true, titleName, 'UseOld', FileName);
                
                minSize = min(numel(ourCmp), numel(Measurement));
                chi = (ourCmp(1:minSize)-Measurement(1:minSize)).^2./(Measurement(1:minSize).*PercentError(1:minSize)/100);
                chi(isnan(chi)) = 0;
                chiSquareGrid(tempIndex,densityIndex) = sum(chi);
                if isnan(chiSquareGrid(tempIndex,densityIndex))
                    %'Error'
                end
                
            end
        end
    end
end

%chiSquareGrid = chiSquareGrid./min(min(chiSquareGrid));

if GenerateReport
    generateComparisonResport(request.Temperature(temperatureIndices), request.CollisionPartnerDensities(densityIndices), chiSquareGrid);
end

end