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

% Indicator of which elements of a universal set are in a particular set.
%
% Input arguments:
% strset:
%    the particular set as a cell array of strings
% struniversal:
%    the universal set as a cell array of strings, all elements in the
%    particular set are expected to be in the universal set
%
% Output arguments:
% ind:
%    a logical vector of which elements of the universal set are found in
%    the particular set

% Copyright 2010 Levente Hunyadi
function ind = strsetmatch(strset, struniversal)

assert(iscellstr(strset), 'strsetmatch:ArgumentTypeMismatch', ...
    'The particular set is expected to be a cell array of strings.');
assert(iscellstr(struniversal), 'strsetmatch:ArgumentTypeMismatch', ...
    'The particular set is expected to be a cell array of strings.');

ind = false(size(struniversal));
for k = 1 : numel(struniversal)
    ind(k) = ~isempty(strmatch(struniversal{k}, strset, 'exact'));
end
