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

classdef (Sealed) Constants < handle
    % Contains all the physical constants used in the program
    
    properties (Constant = true)
        % Plank constant [erg * s]
        h = 6.62606896*10^-27; 
        % Boltzmann constant [erg / K]
        k = 1.3806504*10^-16; 
        % Speed of light [cm / s]
        c = 29979245800; 
        % PI
        pi = 3.141592653589;
        % Velocity gradient conversion factor from [km / s pc] to [1/s]
        dVdRConversionFactor = 10^5 / (3.08568025 * 10^18); 
    end
    
    methods (Access = private)
        function out = Constants ()
            % Private so that you can't instatiate.
        end
    end
end
