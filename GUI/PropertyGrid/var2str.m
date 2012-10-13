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

% Textual representation of any MatLab value.

% Copyright 2009 Levente Hunyadi
function s = var2str(value)

if islogical(value) || isnumeric(value)
    s = num2str(value);
elseif ischar(value) && isvector(value)
    s = reshape(value, 1, numel(value));
elseif isjava(value)
    s = char(value);  % calls java.lang.Object.toString()
else
    try
        s = char(value);
    catch %#ok<CTCH>
        s = '[no preview available]';
    end
end
