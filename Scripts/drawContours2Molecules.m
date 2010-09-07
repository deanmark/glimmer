function drawContours2Molecules

HCOPlus = WorkspaceHelper.GetLVGResultFromWorkspace('HCO+ - T60K');
HCN = WorkspaceHelper.GetLVGResultFromWorkspace('HCN - T60K x 2');

ResultsPairs = ...
    [HCN HCOPlus;
    HCOPlus HCOPlus];    

%levels != J . levels are count 1, J is count 0.
LevelPairs = ...
    [4 4;
    4 2];

ContourLevels = {[0.4 0.5 0.5 0.7], [5 10 20 ]};

%%%%% DON'T CHANGE CODE BELOW HERE

[Ratios, RatioTitles] = Scripts.CalculateIntensityRatios(ResultsPairs, LevelPairs);

Scripts.DrawContours(Ratios, RatioTitles, ContourLevels, HCOPlus.OriginalRequest.VelocityDerivative, HCOPlus.OriginalRequest.CollisionPartnerDensities, HCOPlus.OriginalRequest.Temperature, ...
    'y', HCOPlus.OriginalRequest.CollisionPartnerDensities, 'x', 10^5 * HCOPlus.OriginalRequest.MoleculeDensity(1) ./ HCOPlus.OriginalRequest.VelocityDerivative, ...
    'xName', 'N_H_C_O_+ / dVdr', 'yName', 'n_H_2');

end