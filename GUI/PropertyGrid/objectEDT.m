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

function result = objectEDT(constructor, varargin)
% Auto-delegate Java object method calls to Event Dispatch Thread (EDT).

% Copyright 2010 Levente Hunyadi

error(nargchk(1, 256, nargin));
validateattributes(constructor, {'char'}, {'nonempty','row'});

v = sscanf(version, '%u.%u');  % major and minor version number
if v(1) > 7 || v(1) == 7 && v(2) > 6  % > 7.6, i.e. > MatLab 2008a
    result = javaObjectEDT(constructor, varargin{:});
else
    result = feval(constructor, varargin{:});
end
