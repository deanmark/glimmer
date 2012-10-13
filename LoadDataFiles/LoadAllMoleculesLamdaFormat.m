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

function LoadAllMoleculesLamdaFormat
%LOADALLMOLECULES Loads all molecules in lamda data directory to workspace

lamdaDataFilesFileEnding = '*.dat';

Molecules = WorkspaceHelper.GetMoleculesHashFromWorkspace();

lamdaFilesPath = FileIOHelper.LamdaMolecularDataFilesPath();
lamdaFilesSearchString = fullfile(lamdaFilesPath, lamdaDataFilesFileEnding);
dataFiles = dir (lamdaFilesSearchString);

dlg = ProgressDialog('StatusMessage', 'Loading moldata files', 'ShowTimeLeft', true, 'FractionComplete', 0);

for i=1:numel(dataFiles)
    
    fprintf(1, 'Loading %g/%g Files: %s ... ', i, numel(dataFiles), dataFiles(i).name);
    
    if ~Molecules.IsKey(dataFiles(i).name)
        try
            fileName = fullfile(lamdaFilesPath,dataFiles(i).name);
            mol = LoadMoleculeLamdaFormat(fileName);
            Molecules.Put(dataFiles(i).name,mol);
            fprintf(1, 'Loaded\n');
        catch ME
            fprintf(1, 'Error!\n%s\n', ME.getReport);
        end
    else
        fprintf(1, 'Already Loaded\n');
    end
       
    dlg.FractionComplete = i/numel(dataFiles);
    
end

delete(dlg);

eval([WorkspaceHelper.MoleculesVariableName '= WorkspaceHelper.GetMoleculesHashFromWorkspace();']);
save  (FileIOHelper.StandardMoleculeFilePath,  WorkspaceHelper.MoleculesVariableName);

end
