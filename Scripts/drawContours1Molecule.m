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

function drawContours1Molecule()

Result = WorkspaceHelper.GetLVGResultFromWorkspace('12CO - DVDR10');
% 
%levels != J . levels are count 1, J is count 0.
%LevelPairs = [41 25; 25 18];
LevelPairs = [16 15; 16 20];
%LevelPairs = [26 21];

ContourLevels = {[1.0826 1.0826],[3.6358 3.6358]};
%ContourLevels = {[5.959*0.94 5.959*1.06]};

Scripts.DrawContours1Molecule(Result, LevelPairs, ContourLevels);

%Scripts.DrawMax1Molecule(ResultsRadex, ContourLevels);

end
