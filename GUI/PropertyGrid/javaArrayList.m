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

% Converts a MatLab array into a java.util.ArrayList.
%
% Input arguments:
% array:
%    a MatLab row or column vector (with elements of any type)
%
% Output arguments:
% list:
%    a java.util.ArrayList instance
%
% See also: javaArray

% Copyright 2010 Levente Hunyadi
function list = javaArrayList(array)

assert(isvector(array), 'javaArrayList:DimensionMismatch', ...
	'Row or column vector expected.');
list = java.util.ArrayList;
if iscell(array)  % convert cell array into ArrayList
	for k = 1 : numel(array)
		list.add(array{k});
	end
else  % convert (numeric) array into ArrayList
	for k = 1 : numel(array)
		list.add(array(k));
	end
end
