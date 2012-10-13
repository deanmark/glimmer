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

% Assigns the given value to the named property of an object or structure.
% This function can deal with nested properties.
%
% Input arguments:
% obj:
%    the structure, handle or value object the value should be assigned to
% name:
%    a property name with dot (.) separating property names at
%    different hierarchy levels
% value:
%    the value to assign to the property at the deepest hierarchy
%    level
%
% Output arguments:
% obj:
%    the updated object or structure, optional for handle objects
%
% Example:
%    obj = struct('surface', struct('nested', 10));
%    obj = nestedassign(obj, 'surface.nested', 23);
%    disp(obj.surface.nested);  % prints 23
%
% See also: nestedfetch

% Copyright 2010 Levente Hunyadi
function obj = nestedassign(obj, name, value)
    if ~iscell(name)
        nameparts = strsplit(name, '.');
    else
        nameparts = name;
    end
    obj = nestedassign_recurse(obj, nameparts, value);
end
        
function obj = nestedassign_recurse(obj, name, value)
% Assigns the given value to the named property of an object.
%
% Input arguments:
% obj:
%    the handle or value object the value should be assigned to
% name:
%    a cell array of the composite property name
% value:
%    the value to assign to the property at the deepest hierarchy
%    level
    if numel(name) > 1
        obj.(name{1}) = nestedassign_recurse(obj.(name{1}), name(2:end), value);
    else
        obj.(name{1}) = value;
    end
end
