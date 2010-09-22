function compare2Results ()
%COMPARE2RESULTS visually compare the results of two runs

Result1 = WorkspaceHelper.GetLVGResultFromWorkspace('Radex - HCO+ - T60K');
Result2 = WorkspaceHelper.GetLVGResultFromWorkspace('HCO+ - T60K');

CompareType = ComparisonTypeCodes.Tau;

%%%%% DON'T CHANGE CODE BELOW HERE

p = mfilename('fullpath'); %returns path of current script.
ScriptsDirectory = fileparts(p);
picsPath = fullfile(ScriptsDirectory, '..', 'Results', 'RadexCompareOutput', 'pics');
[status, message, messageid] = rmdir(picsPath, 's');
mkdir(picsPath);

DiffGrid = zeros(numel(Result1.OriginalRequest.Temperature),numel(Result1.OriginalRequest.CollisionPartnerDensities));

for dvdrKmParsec = 1:numel(Result1.OriginalRequest.VelocityDerivative)

    for temp = 1:numel(Result1.OriginalRequest.Temperature)
        
        for dens = 1:numel(Result1.OriginalRequest.CollisionPartnerDensities)
            
            %Compare results using a graph
            picFileName = sprintf('Temperature%g_%g.jpg',Result1.OriginalRequest.Temperature(temp), dens);
            FileName = fullfile(picsPath, picFileName);
            %
      
            [cmp1, cmp1Title, cmp2, cmp2Title, YLabel, FixYAxis] = runParameters (Result1, Result2, CompareType, temp, dens, dvdrKmParsec);
      
            Scripts.Compare2Results(cmp1, cmp1Title, cmp2, cmp2Title, YLabel, FixYAxis, Result1.OriginalRequest.CollisionPartnerDensities(dens), Result1.OriginalRequest.Temperature(temp), ...
                Result1.OriginalRequest.VelocityDerivative(dvdrKmParsec), FileName);
            
            diff = Scripts.PopulationDiff(cmp1, cmp2);
            
            DiffGrid(temp,dens) = 100*max(diff);
            if any (isnan(diff)) %|| RadexConverged == 0
                'Error'
            end
            
        end
    end
end

generateComparisonResport(Result1.OriginalRequest.Temperature, Result1.OriginalRequest.CollisionPartnerDensities, DiffGrid);

end


function [cmp1, cmp1Title, cmp2, cmp2Title, YLabel, FixYAxis] = runParameters (Result1, Result2, ComparisonType, tempIndex, densIndex, dvdrKmParsecIndex)

cmp1Title = RunTypeCodes.ToStringGUIFormat(Result1.OriginalRequest.RunTypeCode);
cmp2Title = RunTypeCodes.ToStringGUIFormat(Result2.OriginalRequest.RunTypeCode);

switch ComparisonType
    case ComparisonTypeCodes.Population
        
        cmp1 = Result1.Population(:,tempIndex,densIndex,dvdrKmParsecIndex);
        cmp2 = Result2.Population(:,tempIndex,densIndex,dvdrKmParsecIndex);
        YLabel = 'x - Fractional population';
        FixYAxis = true;
        
    case ComparisonTypeCodes.Intensities
        
        cmp1 = Result1.Intensities(:,tempIndex,densIndex,dvdrKmParsecIndex);
        cmp2 = Result2.Intensities(:,tempIndex,densIndex,dvdrKmParsecIndex);
        YLabel = 'Intensities';
        FixYAxis = false;

        %normalize intensities
        if max(cmp1)~=0 && max(cmp2) ~=0
            cmp2 = cmp2.* (max(cmp1)/max(cmp2));
        end
        
    case ComparisonTypeCodes.Beta
                
        cmp1 = Result1.FinalBetaCoefficients(:,tempIndex,densIndex,dvdrKmParsecIndex);
        cmp2 = Result2.FinalBetaCoefficients(:,tempIndex,densIndex,dvdrKmParsecIndex);
        YLabel = 'Beta';
        FixYAxis = false;        
                
    case ComparisonTypeCodes.Tau
                
        cmp1 = Result1.FinalTauCoefficients(:,tempIndex,densIndex,dvdrKmParsecIndex);
        cmp2 = Result2.FinalTauCoefficients(:,tempIndex,densIndex,dvdrKmParsecIndex);
        YLabel = 'Tau';
        FixYAxis = false;
        
    otherwise
        ME = MException('VerifyInput:unknownRunTypeCode','Error in input. Comparison Type [%d] is unknown', ComparisonType);
        throw(ME);
end

end