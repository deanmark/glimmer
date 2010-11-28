function fitModelToMeasurement()

Result = WorkspaceHelper.GetLVGResultFromWorkspace('PACS LVG - High - Best fit');
Measurement = evalin('base', 'PacsHigh');
PercentError = evalin('base', 'ErrorHigh');

% Result = WorkspaceHelper.GetLVGResultFromWorkspace('PACS LVG - Middle - Best fit');
% Measurement = evalin('base', 'PacsMiddle');
% PercentError = evalin('base', 'ErrorMiddle');

% Result = WorkspaceHelper.GetLVGResultFromWorkspace('PACS LVG - Low - Best fit');
% Measurement = evalin('base', 'PacsLow');
% PercentError = evalin('base', 'ErrorLow');

%dvdrKmParsecIndices = 1:numel(Result.OriginalRequest.VelocityDerivative);
dvdrKmParsecIndices = find(Result.OriginalRequest.VelocityDerivative==1);
% startIndex = find(Result.OriginalRequest.Temperature==100);
temperatureIndices = 1:find(Result.OriginalRequest.Temperature==5);
 %temperatureIndices = endIndex:numel(Result.OriginalRequest.Temperature);
densityIndices = 1:numel(Result.OriginalRequest.CollisionPartnerDensities);
%densityIndices = find(Result.OriginalRequest.CollisionPartnerDensities==3e5);
moleculeAbundanceIndices = 1:numel(Result.OriginalRequest.MoleculeAbundanceRatios);

SaveImages = 1;
GenerateReport = 1;
ShowUpperAndLowerBounds = 0;

YLabel = 'Intensity [W m^-^2]';
XLabel = '';

YRange = [5e-18 3e-16];

%%%%%

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
                    picFileName = sprintf('Temperature%g_%g.jpg',request.Temperature(tempIndex), find(densityIndices==densityIndex));
                    FileName = fullfile(picsPath, picFileName);
                else
                    FileName = '';
                end
                
                %normalize results.
%                 ourCmp = Result.Intensities(:,tempIndex,densityIndex,dvdrKmParsecIndex);
%                 rawColumnDensityFactor = 1.1e-16/max(ourCmp);
%                 ourCmp = ourCmp*rawColumnDensityFactor;
                
                [val, ind] = max(Measurement);
                ourCmp = Result.Intensities(:,tempIndex,densityIndex,dvdrKmParsecIndex);
                rawColumnDensityFactor = Measurement(ind)/max(ourCmp);
                ourCmp = ourCmp*rawColumnDensityFactor;
                
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
                Scripts.CompareResults(data, plotArguments, XLabel, YLabel, YRange, true, titleName, 'Add', FileName);
                
                minSize = min(numel(ourCmp), numel(Measurement));
                chi = ((ourCmp(1:minSize)-Measurement(1:minSize))./(Measurement(1:minSize).*PercentError(1:minSize)/100)).^2;
                chi(isnan(chi)) = 0;
                chiSquareGrid(find(temperatureIndices==tempIndex),find(densityIndices==densityIndex)) = sum(chi);
                
            end
        end
    end
end

%chiSquareGrid = chiSquareGrid./min(min(chiSquareGrid));

if GenerateReport
    generateComparisonResport(request.Temperature(temperatureIndices), request.CollisionPartnerDensities(densityIndices), chiSquareGrid);
end

end