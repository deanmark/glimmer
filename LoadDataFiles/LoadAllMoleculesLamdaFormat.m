function LoadAllMoleculesLamdaFormat
%LOADALLMOLECULES Loads all molecules in lamda data directory to workspace

lamdaDataFilesFileEnding = '*.dat';

Molecules = getMoleculeDataFromWorkspace();

p = mfilename('fullpath');
path = fileparts(p);
lamdaFilesPath = fullfile(path, '..', 'DataFiles', 'Lamda');
lamdaFilesSearchString = fullfile(lamdaFilesPath, lamdaDataFilesFileEnding);
dataFiles = dir (lamdaFilesSearchString);

for i=1:numel(dataFiles)
    
    errorLoading = 0;
    
    if ~Molecules.IsKey(dataFiles(i).name)
        try
            fileName = fullfile(lamdaFilesPath,dataFiles(i).name);
            mol = LoadMoleculeLamdaFormat(fileName);
            Molecules.Put(dataFiles(i).name,mol);
        catch ME
            errorLoading = 1;
            display(ME);
        end
    else
        mol = Molecules.Get(dataFiles(i).name);
    end
    
    if ~errorLoading
        fprintf(1, 'Loaded %g/%g Files: %s . Molecule: %s\n', i, numel(dataFiles), dataFiles(i).name, mol.MoleculeName);
    else
        fprintf(1, 'Error Loading File. %g/%g Files: %s\n', i, numel(dataFiles), dataFiles(i).name);
    end
    
end

end

function Molecules = getMoleculeDataFromWorkspace ()

ws = 'base';
moleculesVariableName = 'Molecules';

moleculesVariableExists = ~isempty(evalin(ws, sprintf('who(''%s'')', moleculesVariableName)));

if moleculesVariableExists
    [Molecules] = evalin(ws, moleculesVariableName);
else
    Molecules = Hashtable();
    assignin(ws, moleculesVariableName, Molecules);
end

end