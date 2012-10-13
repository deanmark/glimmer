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
