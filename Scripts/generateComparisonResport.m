p = mfilename('fullpath'); %returns path of current script.
ScriptsDirectory = fileparts(p);
radexComparePath = fullfile(ScriptsDirectory, '..', 'Results', 'RadexCompareOutput');

data = cell(size(Results));

for i=1:size(Results,1)
    for j=1:size(Results,2)
       data{i,j} = sprintf('<a href="./pics/Temperature%g_%g.jpg">%2.2f</a>', Temperatures(i), j, Results(i,j));
    end    
end

colheads = cell(size(CollisionPartnerDensities));

for i=1:numel(CollisionPartnerDensities)
    colheads{i} = sprintf('%4.3g cm^-3',CollisionPartnerDensities(i));
end

rowheads = cell(size(Temperatures));

for i=1:numel(Temperatures)
    rowheads{i} = sprintf('%g K',Temperatures(i));
end

rowheads = transpose(rowheads);

table_cell = [[cell(1);rowheads] [colheads; num2cell(data)]];

html_table(table_cell, fullfile(radexComparePath,'index.html'),'FirstRowIsHeading',1, 'FirstColIsHeading',1);