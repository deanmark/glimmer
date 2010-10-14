function drawContours2Molecules
% % 

CO = WorkspaceHelper.GetLVGResultFromWorkspace('CO-LVG-Varying Nh2/dvdr - Modified');    
HCN = WorkspaceHelper.GetLVGResultFromWorkspace('HCN-LVG-Varying Nh2/dvdr - Modified');

%  CO = WorkspaceHelper.GetLVGResultFromWorkspace('CO-LVG-Varying Nh2/dvdr - Modified');
%  HCN = WorkspaceHelper.GetLVGResultFromWorkspace('HCN-LVG-Varying Nh2/dvdr - Modified');

% CO = WorkspaceHelper.GetLVGResultFromWorkspace('CO-Radex-100K-/10');    
% HCN = WorkspaceHelper.GetLVGResultFromWorkspace('HCN-Radex-100K-/10');

ResultsPairs = ...
    [HCN CO];    

%levels != J . levels are count 1, J is count 0.
LevelPairs = ...
    [2 3];

ContourLevels = {[50]};
%ContourLevels = {[0.4 0.5 0.5 0.7], [5 10 20 ]};

%%%%% DON'T CHANGE CODE BELOW HERE

[Ratios, RatioTitles] = Scripts.CalculateIntensityRatios(ResultsPairs, LevelPairs);

%DrawContours(Data, DataTitles, ContourLevels, PopulationRequest, XAxisProperty, YAxisProperty, varargin)

Ratios(Ratios>10)=NaN;
Ratios(Ratios<=0)=NaN;
Ratios(Ratios==Inf)=NaN;

Scripts.DrawContours(Ratios, RatioTitles, ContourLevels, CO.OriginalRequest, LVGParameterCodes.VelocityDerivative, LVGParameterCodes.CollisionPartnerDensity, ...
    'x', 1e6 ./ CO.OriginalRequest.VelocityDerivative, ...
    'xName', 'N_H_2/dvdr', 'yName', 'n_H_2', 'titleName', 'T=100[K], X_H_C_N/X_C_O=1e-4');

end