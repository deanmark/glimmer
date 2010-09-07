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