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

% Publicly accessible dependent properties of an object.
%
% See also: meta.property

% Copyright 2010 Levente Hunyadi
function dependent = getdependentproperties(obj)

dependent = {};
if isstruct(obj)  % structures have no dependent properties
    return;
end

try
    clazz = metaclass(obj);
catch %#ok<CTCH>
    return;  % old-style class (i.e. not defined with the classdef keyword) have no dependent properties
end

k = 0;  % number of dependent properties found
n = numel(clazz.Properties);  % maximum number of properties
dependent = cell(n, 1);
for i = 1 : n
    property = clazz.Properties{i};
    if property.Abstract || property.Hidden || ~strcmp(property.GetAccess, 'public') || ~property.Dependent
        continue;  % skip abstract, hidden, inaccessible and independent properties
    end
    
    k = k + 1;
    dependent{k} = property.Name;
end
dependent(k+1:end) = [];  % drop unused cells
