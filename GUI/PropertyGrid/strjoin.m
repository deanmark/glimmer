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

% Concatenates a cell array of strings.
%
% Input arguments:
% adjoiner:
%    string separating each neighboring element
% strings:
%    a cell array of strings to join
%
% See also: strsplit, cell2mat

% Copyright 2008-2009 Levente Hunyadi
function string = strjoin(adjoiner, strings)

validateattributes(adjoiner, {'char'}, {'vector'});
validateattributes(strings, {'cell'}, {'vector'});
assert(iscellstr(strings), ...
    'strjoin:ArgumentTypeMismatch', ...
    'The elements to join should be stored in a cell vector of strings (character arrays).');
if isempty(strings)
    string = '';
    return;
end

% arrange substrings into cell array of strings
concat = cell(1, 2 * numel(strings) - 1);  % must be row vector
j = 1;
concat{j} = strings{1};
for i = 2 : length(strings)
    j = j + 1;
    concat{j} = adjoiner;
    j = j + 1;
    concat{j} = strings{i};
end

% concatenate substrings preserving spaces
string = cell2mat(concat);
