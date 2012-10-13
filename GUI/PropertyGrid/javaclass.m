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

% Return java.lang.Class instance for MatLab type.
%
% Input arguments:
% mtype:
%    the MatLab name of the type for which to return the java.lang.Class
%    instance
% ndims:
%    the number of dimensions of the MatLab data type
%
% See also: class

% Copyright 2009-2010 Levente Hunyadi
function jclass = javaclass(mtype, ndims)

validateattributes(mtype, {'char'}, {'nonempty','row'});
if nargin < 2
    ndims = 0;
else
    validateattributes(ndims, {'numeric'}, {'nonnegative','integer','scalar'});
end

if ndims == 1 && strcmp(mtype, 'char');  % a character vector converts into a string
    jclassname = 'java.lang.String';
elseif ndims > 0
    jclassname = javaarrayclass(mtype, ndims);
else
    % The static property .class applied to a Java type returns a string in
    % MatLab rather than an instance of java.lang.Class. For this reason,
    % use a string and java.lang.Class.forName to instantiate a
    % java.lang.Class object; the syntax java.lang.Boolean.class will not
    % do so.
    switch mtype
        case 'logical'  % logical vaule (true or false)
            jclassname = 'java.lang.Boolean';
        case 'char'  % a singe character
            jclassname = 'java.lang.Character';
        case {'int8','uint8'}  % 8-bit signed and unsigned integer
            jclassname = 'java.lang.Byte';
        case {'int16','uint16'}  % 16-bit signed and unsigned integer
            jclassname = 'java.lang.Short';
        case {'int32','uint32'}  % 32-bit signed and unsigned integer
            jclassname = 'java.lang.Integer';
        case {'int64','uint64'}  % 64-bit signed and unsigned integer
            jclassname = 'java.lang.Long';
        case 'single'  % single-precision floating-point number
            jclassname = 'java.lang.Float';
        case 'double'  % double-precision floating-point number
            jclassname = 'java.lang.Double';
        case 'cellstr'  % a single cell or a character array
            jclassname = 'java.lang.String';
        otherwise
            error('java:javaclass:InvalidArgumentValue', ...
                'MatLab type "%s" is not recognized or supported in Java.', mtype);
    end
end
% Note: When querying a java.lang.Class object by name with the method
% jclass = java.lang.Class.forName(jclassname);
% MatLab generates an error. For the Class.forName method to work, MatLab
% requires class loader to be specified explicitly.
jclass = java.lang.Class.forName(jclassname, true, java.lang.Thread.currentThread().getContextClassLoader());

function jclassname = javaarrayclass(mtype, ndims)
% Returns the type qualifier for a multidimensional Java array.

switch mtype
    case 'logical'  % logical array of true and false values
        jclassid = 'Z';
    case 'char'  % character array
        jclassid = 'C';
    case {'int8','uint8'}  % 8-bit signed and unsigned integer array
        jclassid = 'B';
    case {'int16','uint16'}  % 16-bit signed and unsigned integer array
        jclassid = 'S';
    case {'int32','uint32'}  % 32-bit signed and unsigned integer array
        jclassid = 'I';
    case {'int64','uint64'}  % 64-bit signed and unsigned integer array
        jclassid = 'J';
    case 'single'  % single-precision floating-point number array
        jclassid = 'F';
    case 'double'  % double-precision floating-point number array
        jclassid = 'D';
    case 'cellstr'  % cell array of strings
        jclassid = 'Ljava.lang.String;';
    otherwise
        error('java:javaclass:InvalidArgumentValue', ...
            'MatLab type "%s" is not recognized or supported in Java.', mtype);
end
jclassname = [repmat('[',1,ndims), jclassid];
