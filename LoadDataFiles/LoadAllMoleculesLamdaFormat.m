function LoadAllMoleculesLamdaFormat
%LOADALLMOLECULES Loads all molecules in lamda data directory to workspace

lamdaDataFilesFileEnding = '*.dat';

Molecules = WorkspaceHelper.GetMoleculesHashFromWorkspace();

p = mfilename('fullpath');
path = fileparts(p);
lamdaFilesPath = fullfile(path, '..', 'DataFiles', 'Lamda');
lamdaFilesSearchString = fullfile(lamdaFilesPath, lamdaDataFilesFileEnding);
dataFiles = dir (lamdaFilesSearchString);

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
    end
        
end

end