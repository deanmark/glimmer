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

% Sample code for ProgressDialog.

% Copyright 2008-2009 Levente Hunyadi
function example_waitdialog

pause(0.1);

% show progress bar dialog
dlg = ProgressDialog();

maxiter = 50;
dlg.FractionComplete = 0;
dlg.ShowTimeLeft = true;
for iter = 1 : maxiter
    % do any long-running operation
    pause(0.1);
    
    % update progress bar
    dlg.FractionComplete = iter/maxiter;
    
    % update status message
    dlg.StatusMessage = sprintf('%d%% complete', fix(100*iter/maxiter));
end

% destroy progress bar dialog explicitly
delete(dlg);

% create progress bar dialog with custom status message
dlg = ProgressDialog( ...
    'StatusMessage', 'Please wait until operation terminates...', ...
    'FractionComplete', 0.25);
pause(2);

% hide status message
dlg.StatusMessage = [];
dlg.FractionComplete = 1;
pause(2);
% dialog is automatically destroyed when variable dlg is assigned to

switch dlg.Implementation
    case 'java'
        % create progress bar with indeterminate state
        % supported by Java implementation only
        dlg = ProgressDialog( ...
            'StatusMessage', 'Close the dialog to continue', ...
            'Indeterminate', true);
        uiwait(dlg);
end

% demonstrate procedural syntax
dlg = waitdialog(0.0);
pause(1);
waitdialog(dlg, 0.25);
pause(1);
waitdialog(dlg, 0.5, 'Committing...');
pause(1);
waitdialog(dlg, 0.75);
pause(1);
waitdialog(dlg, 'Finalizing...', 1.0);
pause(1);
delete(dlg);
