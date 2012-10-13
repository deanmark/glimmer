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
    
    [pathstr, name, ext] = fileparts(MoldataLinks{i});
    fileName = strcat(name, ext);
    fullFilePath = fullfile(lamdaFilesPath, fileName);
    
    fprintf(1,'%g/%g : %s ... ', i, numel(MoldataLinks), fileName);
    
    try
        urlwrite(MoldataLinks{i}, fullFilePath);
        fprintf(1,'Finished\n');
    catch ME
        fprintf(1, 'Error!\n%s\n', ME.getReport);
    end
    
    dlg.FractionComplete = i/numel(MoldataLinks);    
    
end

delete(dlg);
fprintf(1,'finished!\n');
