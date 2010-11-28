function drawContours2Molecules
% % 

CO = WorkspaceHelper.GetLVGResultFromWorkspace('PACS LVG');    
%HCN = WorkspaceHelper.GetLVGResultFromWorkspace('HCN-LVG-Varying Nh2/dvdr - Modified');

%  CO = WorkspaceHelper.GetLVGResultFromWorkspace('CO-LVG-Varying Nh2/dvdr - Modified');
%  HCN = WorkspaceHelper.GetLVGResultFromWorkspace('HCN-LVG-Varying Nh2/dvdr - Modified');

% CO = WorkspaceHelper.GetLVGResultFromWorkspace('CO-Radex-100K-/10');    
% HCN = WorkspaceHelper.GetLVGResultFromWorkspace('HCN-Radex-100K-/10');

ResultsPairs = ...
    [CO CO; CO CO];    

%levels != J . levels are count 1, J is count 0.
LevelPairs = ...
    [7 4;7 8];

ContourLevels = {[2.3884 2.3884]; [1.3984 1.3984]};
%ContourLevels = {[0.4 0.5 0.5 0.7], [5 10 20 ]};

%%%%% DON'T CHANGE CODE BELOW HERE

[Ratios, RatioTitles] = Scripts.CalculateIntensityRatios(ResultsPairs, LevelPairs);

%DrawContours(Data, DataTitles, ContourLevels, PopulationRequest, XAxisProperty, YAxisProperty, varargin)

Scripts.DrawContours(Ratios, RatioTitles, ContourLevels, CO.OriginalRequest, LVGParameterCodes.CollisionPartnerDensity, LVGParameterCodes.Temperature);
    %'xName', 'N_H_2/dvdr', 'yName', 'n_H_2', 'titleName', 'T=100[K], X_H_C_N/X_C_O=1e-4');

end