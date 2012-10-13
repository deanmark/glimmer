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

% Demonstrates how to use the matrix editor.
%
% See also: MatrixEditor

% Copyright 2010 Levente Hunyadi
function example_matrixeditor

fig = figure( ...
    'MenuBar', 'none', ...
    'Name', 'Matrix editor demo - Copyright 2010 Levente Hunyadi', ...
    'NumberTitle', 'off', ...
    'Toolbar', 'none');
editor = MatrixEditor(fig, ...
    'Item', [1,2,3,4;5,6,7,8;9,10,11,12], ...
    'Type', PropertyType('denserealdouble','matrix'));
uiwait(fig);
disp(editor.Item);
