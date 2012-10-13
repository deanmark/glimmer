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

% Produce error in the context of the caller function.
% The function throws a MatLab exception that lacks the stack frame of the
% caller function.

% Copyright 2009 Levente Hunyadi
function callererror(identifier, message, varargin)

if nargin > 2
    text = sprintf(message, varargin{:});
else
    text = message;
end

errorstruct = struct( ...
    'message', text, ...
    'identifier', identifier, ...
    'stack', dbstack(2));  % remove the context of (1) the caller function and (2) this function
error(errorstruct);
