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

% Find handle graphics object with user data check.
% Retrieves those handle graphics objects (HGOs) that have the specified
% Tag property and whose UserData property satisfies the given predicate.
%
% Input arguments:
% fcn:
%    a predicate (a function that returns a logical value) to test against
%    the HGO's UserData property
% tag (optional):
%    a string tag to restrict the set of controls to investigate
%
% See also: findobj

% Copyright 2010 Levente Hunyadi
function h = findobjuser(fcn, tag)

validateattributes(fcn, {'function_handle'}, {'scalar'});
if nargin < 2 || isempty(tag)
    tag = '';
else
    validateattributes(tag, {'char'}, {'row'});
end

%hh = get(0, 'ShowHiddenHandles');
%cleanup = onCleanup(@() set(0, 'ShowHiddenHandles', hh));  % restore visibility on exit or exception

if ~isempty(tag)
    % look among all handles (incl. hidden handles) to help findobj locate the object it seeks
    h = findobj(findall(0), '-property', 'UserData', '-and', 'Tag', tag);  % more results if multiple matching HGOs exist
else
    h = findobj(findall(0), '-property', 'UserData');
end
h = unique(h);
f = arrayfun(@(handle) fcn(get(handle, 'UserData')), h);
h = h(f);
