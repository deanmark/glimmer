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

% Splits a string into a cell array of strings.
%
% Input arguments:
% string:
%    a string to split into a cell array
% adjoiner:
%    string separating each neighboring element
%
% See also: strjoin

% Copyright 2008-2009 Levente Hunyadi
function strings = strsplit(string, adjoiner)

if nargin < 2
    adjoiner = sprintf('\n');
end

ix = strfind(string, adjoiner);
strings = cell(numel(ix)+1, 1);
ix = [0 ix numel(string)+1];  % place implicit adjoiners before and after string
for k = 2 : numel(ix)
    strings{k-1} = string(ix(k-1)+1:ix(k)-1);
end
