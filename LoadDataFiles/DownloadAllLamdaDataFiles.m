function DownloadAllLamdaDataFiles (lamdaWebsite)

% get all moldata links
%lamda = 'http://www.strw.leidenuniv.nl/~moldata/';

lamdaWebsite = lamdaWebsite{1};

dlg = ProgressDialog( ...
    'StatusMessage', 'Downloading main page', ...
    'Indeterminate', true);

fprintf(1,'Downloading main page from: %s\n', lamdaWebsite);
mainSite = urlread(lamdaWebsite);
[tmp links] = regexp(mainSite,'(?<=href=").*?(?=")', 'tokens', 'match');
distilledLinks = links( strmatch(lamdaWebsite,links));
MoldataLinks = {};

dlg = ProgressDialog('StatusMessage', 'Processing links', 'ShowTimeLeft', true, 'FractionComplete', 0);
fprintf(1,'processing links...\n');

for i=1:numel(distilledLinks)

    subsite = urlread(distilledLinks{i});
    [tmp subLinks] = regexp(subsite,'(?<=href=").*?(?=")', 'tokens', 'match');
    
    interimPath = fullfile(lamdaWebsite, 'datafiles');
    path = strrep(interimPath, '\', '/');
    molLinks = subLinks(strmatch(path,subLinks));
    
    if numel(molLinks) > 0
        MoldataLinks = cat(2, MoldataLinks ,molLinks);
    end
    
    dlg.FractionComplete = i/numel(distilledLinks);
    fprintf(1,'%g/%g : %s\n', i, numel(distilledLinks), distilledLinks{i});  
    
end
delete(dlg);
dlg = ProgressDialog('StatusMessage', 'Downloading and converting moldata files', 'ShowTimeLeft', true, 'FractionComplete', 0);

% download all moldata files
fprintf(1,'downloading moldata files...\n');
lamdaFilesPath = FileIOHelper.LamdaMolecularDataFilesPath();

for i=1:numel(MoldataLinks)
    
    [pathstr, name, ext, versn] = fileparts(MoldataLinks{i});
    fileName = strcat(name, ext);
    fullFilePath = fullfile(lamdaFilesPath, fileName);
    
    fprintf(1,'%g/%g : %s ... ', i, numel(MoldataLinks), fileName);
    
    try
        urlwrite(MoldataLinks{i}, fullFilePath);
        DataFilesHelper.ConvertLamdaFileToLocalFile(fullFilePath);
        fprintf(1,'Finished\n');
    catch ME
        fprintf(1, 'Error!\n%s\n', ME.getReport);
    end
    
    dlg.FractionComplete = i/numel(MoldataLinks);    
    
end

delete(dlg);
fprintf(1,'finished!\n');