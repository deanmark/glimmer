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

% Elegant and easy-to-use progress dialog.
% Copyright 2008-2009 Levente Hunyadi
%
% Object-oriented interface
%   ProgressDialog     - A progress dialog to notify the user of the status an ongoing operation.
%
% Procedural interface
%   progressbar        - Displays a progress dialog to notify the user of an ongoing operation.
%   waitdialog         - Displays a progress dialog to notify the user of an ongoing operation.
%
% Object-oriented utility classes
%   UIControl          - Root class for composite user controls.
%
% Internal utility functions
%   callererror        - Produce error in the context of the caller function.
%   constructor        - Sets public properties of a MatLab object using a name-value list.
%   position2size      - Extracts size information from handle graphics position vector.
%
% Sample code
%   example_waitdialog - Sample code for ProgressDialog.
