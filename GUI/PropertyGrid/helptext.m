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

% Help text associated with a function, class, property or method.
% Spaces are removed as necessary.
%
% See also: helpdialog

% Copyright 2008-2010 Levente Hunyadi
function text = helptext(obj)

if ischar(obj)
    text = gethelptext(obj);
else
    text = gethelptext(class(obj));
end
text = texttrim(text);

function text = gethelptext(key)

persistent dict;
if isempty(dict) && usejava('jvm')
    dict = java.util.Properties();
end

if ~isempty(dict)
    text = char(dict.getProperty(key));  % look up key in cache
    if ~isempty(text)  % help text found in cache
        return;
    end
    text = help(key);
    if ~isempty(text)  % help text returned by help call, save it into cache
        dict.setProperty(key, text);
    end
else
    text = help(key);
end

function lines = texttrim(text)
% Trims leading and trailing whitespace characters from lines of text.
% The number of leading whitespace characters to trim is determined by
% inspecting all lines of text.

loc = strfind(text, sprintf('\n'));
n = numel(loc);
loc = [ 0 loc ];
lines = cell(n,1);
if ~isempty(loc)
    for k = 1 : n
        lines{k} = text(loc(k)+1 : loc(k+1));
    end
end
lines = deblank(lines);

% determine maximum leading whitespace count
f = ~cellfun(@isempty, lines);  % filter for non-empty lines
firstchar = cellfun(@(line) find(~isspace(line), 1), lines(f));  % index of first non-whitespace character
if isempty(firstchar)
    indent = 1;
else
    indent = min(firstchar);
end

% trim leading whitespace
lines(f) = cellfun(@(line) line(min(indent,numel(line)):end), lines(f), 'UniformOutput', false);
