function downloadAllLamdaDataFiles

% get all moldata links
lamda = 'http://www.strw.leidenuniv.nl/~moldata/';

fprintf(1,'downloading moldata files from website: %s\n', lamda);
mainSite = urlread(lamda);
[tmp links] = regexp(mainSite,'(?<=href=").*?(?=")', 'tokens', 'match');
distilledLinks = links( strmatch('http://www.strw.leidenuniv.nl/~moldata/',links));
MoldataLinks = {};

fprintf(1,'processing links...\n');

for i=1:numel(distilledLinks)

    subsite = urlread(distilledLinks{i});
    [tmp subLinks] = regexp(subsite,'(?<=href=").*?(?=")', 'tokens', 'match');
    
    molLinks = subLinks(strmatch('http://www.strw.leidenuniv.nl/~moldata/datafiles/',subLinks));
    
    if numel(molLinks) > 0
        MoldataLinks = cat(2, MoldataLinks ,molLinks);
    end
    
    fprintf(1,'%g/%g : %s\n', i, numel(distilledLinks), distilledLinks{i});  
    
end

% download all moldata files
fprintf(1,'downloading moldata files...\n');

for i=1:numel(MoldataLinks)
    
    [pathstr, name, ext, versn] = fileparts(MoldataLinks{i});
    fileName = strcat(name, ext);
    urlwrite(MoldataLinks{i}, fileName);
    
    fprintf(1,'%g/%g : %s\n', i, numel(MoldataLinks), fileName);  
    
end

fprintf(1,'finished!\n');