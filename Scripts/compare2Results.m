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

function compare2Results ()
%COMPARE2RESULTS visually compare the results of two runs

Result1 = WorkspaceHelper.GetLVGResultFromWorkspace('PACS high - reference');
Result2 = WorkspaceHelper.GetLVGResultFromWorkspace('PACS high - LTE');

dvdrKmParsecIndices = 1:numel(Result.OriginalRequest.VelocityDerivative);
temperatureIndices = 1:numel(Result.OriginalRequest.Temperature);
%temperatureIndices = find(Result.OriginalRequest.Temperature==600);
%collisionPartnerDensityIndices = find(Result.OriginalRequest.CollisionPartnerDensities==3e5);
collisionPartnerDensityIndices = 1:numel(Result.OriginalRequest.CollisionPartnerDensities);
moleculeAbundanceIndices = 1:numel(Result.OriginalRequest.MoleculeAbundanceRatios);


CompareType = ComparisonTypeCodes.Population;

SaveImages = 1;
GenerateReport = 1;

%%%%% DON'T CHANGE CODE BELOW HERE

figure;

if SaveImages
    picsPath = FileIOHelper.ComparisonPicsOutputPath();
    [status, message, messageid] = rmdir(picsPath, 's');
    mkdir(picsPath);
end

DiffGrid = zeros(numel(Result1.OriginalRequest.Temperature),numel(Result1.OriginalRequest.CollisionPartnerDensities));

for dvdrKmParsec = dvdrKmParsecIndices
    for temp = temperatureIndices
        for molAbundance=moleculeAbundanceIndices
            for dens = collisionPartnerDensityIndices
                
                %Compare results using a graph
                picFileName = sprintf('Temperature%g_%g.jpg',Result1.OriginalRequest.Temperature(temp), dens);
                FileName = fullfile(picsPath, picFileName);
                %
                [cmp1, cmp1Title, cmp2, cmp2Title, YLabel, FixYAxis] = runParameters (Result1, Result2, CompareType, temp, dens, dvdrKmParsec,molAbundance);
                
                Data = cell(1,2);
                plotArguments = cell(1,2);
                Data{1} = cmp1;
                Data{2} = cmp2;
                plotArguments{1} = {'DisplayName', cmp1Title};
                plotArguments{2} = {'DisplayName', cmp2Title};

                %(Data, PlotArguments, YLabel, XLabel,YRange, YAxisLog, Title, FileName)
                
                Scripts.CompareResults(Data, plotArguments, YLabel, 'J', );
                
                Scripts.CompareResults(cmp1, cmp1Title, cmp2, cmp2Title, YLabel, FixYAxis, Result1.OriginalRequest.CollisionPartnerDensities(dens), Result1.OriginalRequest.Temperature(temp), ...
                    Result1.OriginalRequest.VelocityDerivative(dvdrKmParsec), FileName);
                
                diff = Scripts.PopulationDiff(cmp1, cmp2);
                
                DiffGrid(temp,dens) = 100*max(diff);
                if any (isnan(diff)) %|| RadexConverged == 0
                    'Error'
                end
            end
        end
    end
end

generateComparisonResport(Result1.OriginalRequest.Temperature, Result1.OriginalRequest.CollisionPartnerDensities, DiffGrid);

end


function [cmp1, cmp1Title, cmp2, cmp2Title, YLabel,XLabel, YRange] = runParameters (Result1, Result2, ComparisonType, tempIndex, densIndex, dvdrKmParsecIndex,molAbundanceIndex)

cmp1Title = RunTypeCodes.ToStringGUIFormat(Result1.OriginalRequest.RunTypeCode);
cmp2Title = RunTypeCodes.ToStringGUIFormat(Result2.OriginalRequest.RunTypeCode);

switch ComparisonType
    case ComparisonTypeCodes.Population
        
        cmp1 = Result1.Population(:,tempIndex,densIndex,dvdrKmParsecIndex,molAbundanceIndex);
        cmp2 = Result2.Population(:,tempIndex,densIndex,dvdrKmParsecIndex,molAbundanceIndex);
        YLabel = 'x - Fractional population';
        FixYAxis = true;
        
    case ComparisonTypeCodes.IntegratedIntensity
        
        cmp1 = Result1.IntegratedIntensity(:,tempIndex,densIndex,dvdrKmParsecIndex,molAbundanceIndex);
        cmp2 = Result2.IntegratedIntensity(:,tempIndex,densIndex,dvdrKmParsecIndex,molAbundanceIndex);
        YLabel = 'Integrated Intensity';
        FixYAxis = false;

        %normalize intensities
        if max(cmp1)~=0 && max(cmp2) ~=0
            cmp2 = cmp2.* (max(cmp1)/max(cmp2));
        end
        
    case ComparisonTypeCodes.Beta
                
        cmp1 = Result1.FinalBetaCoefficients(:,tempIndex,densIndex,dvdrKmParsecIndex,molAbundanceIndex);
        cmp2 = Result2.FinalBetaCoefficients(:,tempIndex,densIndex,dvdrKmParsecIndex,molAbundanceIndex);
        YLabel = 'Beta';
        FixYAxis = false;        
                
    case ComparisonTypeCodes.Tau
                
        cmp1 = Result1.FinalTauCoefficients(:,tempIndex,densIndex,dvdrKmParsecIndex,molAbundanceIndex);
        cmp2 = Result2.FinalTauCoefficients(:,tempIndex,densIndex,dvdrKmParsecIndex,molAbundanceIndex);
        YLabel = 'Tau';
        FixYAxis = false;
        
    otherwise
        ME = MException('VerifyInput:unknownRunTypeCode','Error in input. Comparison Type [%d] is unknown', ComparisonType);
        throw(ME);
end

end
