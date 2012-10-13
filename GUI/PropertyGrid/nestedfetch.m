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

% Fetches the value of the named property of an object or structure.
% This function can deal with nested properties.
%
% Input arguments:
% obj:
%    the handle or value object the value should be assigned to
% name:
%    a property name with dot (.) separating property names at
%    different hierarchy levels
% value:
%    the value to assign to the property at the deepest hierarchy
%    level
%
% Example:
%    obj = struct('surface', struct('nested', 23));
%    value = nestedfetch(obj, 'surface.nested');
%    disp(value);  % prints 23
%
% See also: nestedassign

% Copyright 2010 Levente Hunyadi
function value = nestedfetch(obj, name)
    if ~iscell(name)
        nameparts = strsplit(name, '.');
    else
        nameparts = name;
    end
    value = nestedfetch_recurse(obj, nameparts);
end
        
function value = nestedfetch_recurse(obj, name)
    if numel(name) > 1
        value = nestedfetch_recurse(obj.(name{1}), name(2:end));
    else
        value = obj.(name{1});
    end
end
