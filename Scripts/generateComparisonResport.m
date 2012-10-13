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
