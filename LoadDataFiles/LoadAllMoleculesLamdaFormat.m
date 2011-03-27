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