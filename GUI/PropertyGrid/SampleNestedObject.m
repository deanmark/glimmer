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

% Sample nested object to test expandable properties.

% Copyright 2008-2009 Levente Hunyadi
classdef SampleNestedObject
    properties
        RealDoubleScalar = pi;
        RealDoubleRow = [1.5,2.5,3.5,4.5];
        RealDoubleColumn = [1.5;2.5;3.5;4.5];
        RealDoubleMatrix = [1.5,2.5;3.5,4.5];
        RealSingleMatrix = single([1.5,2.5;3.5,4.5]);
        ComplexDoubleScalar = 1.5 + 2.5i;
        ComplexDoubleMatrix = [1.5,2.5i;3.5i,4.5];
        ComplexSingleMatrix = single([1.5,2.5i;3.5i,4.5])
        IntegerScalar = int32(32);
        IntegerMatrix = int32([1,2;3,4]);
        Logical = true;
        LogicalVector = [true true false];
        String = 'this is a string';
    end
    properties (Dependent)
        DependentProperty;
    end
    properties (Dependent, Hidden)
        Caption;
    end        
    properties (Access = private)
        PrivateProperty = 'private';
    end
    properties (Access = protected)
        ProtectedProperty = 'protected';
    end
    methods
        function str = char(self)
            str = self.Caption;
        end
        
        function cap = get.Caption(self) %#ok<INUSD>
            cap = 'SampleNestedObject';
        end

        function Method(this)
            disp(this.PrivateProperty);
        end
        
        function value = get.DependentProperty(self)
            value = self.String;
        end
        
        function self = set.DependentProperty(self, value)
            self.String = value;
        end
    end
end
