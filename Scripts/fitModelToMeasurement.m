function Untitled()

Result = WorkspaceHelper.GetLVGResultFromWorkspace('PACS Reference');
Measurement = evalin('base', 'PacsHigh');
PercentError = evalin('base', 'ErrorHigh');

dvdrKmParsecIndices = 1:numel(Result.OriginalRequest.VelocityDerivative);
%temperatureIndices = 1:numel(Result.OriginalRequest.Temperature);
temperatureIndices = find(Result.OriginalRequest.Temperature==600);
%densityIndices = 1:numel(Result.OriginalRequest.CollisionPartnerDensities);
densityIndices = find(Result.OriginalRequest.CollisionPartnerDensities==3e5);

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
            [val, ind] = max(Measurement);
            ourCmp = Result.Intensities(:,tempIndex,densityIndex,dvdrKmParsecIndex);
            columnDensityFactor = Measurement(ind)/max(ourCmp);
            ourCmp = ourCmp*columnDensityFactor;
            
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
                request.CollisionPartnerDensities(densityIndex), request.MoleculeDensity(densityIndex), request.CloudColumnDensity(densityIndex)*columnDensityFactor);
            
            %Data, PlotArguments, YLabel, XLabel, YRange, YAxisLog, Title, FileName
            Scripts.CompareResults(data, plotArguments, YLabel, XLabel, YRange, true, titleName, FileName);
                        
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

chiSquareGrid = chiSquareGrid./min(min(chiSquareGrid));

if GenerateReport
    generateComparisonResport(request.Temperature(temperatureIndices), request.CollisionPartnerDensities(densityIndices), chiSquareGrid);
end

end