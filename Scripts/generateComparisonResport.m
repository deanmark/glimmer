function generateComparisonResport(Temperatures, CollisionPartnerDensities, DiffGrid)

data = cell(size(DiffGrid));

for i=1:size(DiffGrid,1)
    for j=1:size(DiffGrid,2)
        
        if (1/100) < min(DiffGrid(:)) && max(DiffGrid(:)) < 100
            data{i,j} = sprintf('<a href="./pics/Temperature%g_%g.jpg">%2.2f</a>', Temperatures(i), j, DiffGrid(i,j));            
        else
            data{i,j} = sprintf('<a href="./pics/Temperature%g_%g.jpg">%2.2e</a>', Temperatures(i), j, DiffGrid(i,j));
        end

    end
end

% colheads = cell(size(dvdrKmParsecArray));
%
% for i=1:numel(dvdrKmParsecArray)
%     colheads{i} = sprintf('%4.3g [km s-1 pc-1]',dvdrKmParsecArray(i));
% end

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

html_table(table_cell, fullfile(FileIOHelper.ComparisonOutputPath,'index.html'),'FirstRowIsHeading',1, 'FirstColIsHeading',1);

end