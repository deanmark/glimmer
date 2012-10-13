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

result1 = LVGResults.Get('Low component - LTE reference');
result2 = LVGResults.Get('PACS LVG');

% result1 = LVGResults.Get('PACS high - LVG');
% result2 = LVGResults.Get('PACS high - LTE');


%(DrawType, PopulationResult, VelocityDerivativeIndices, TemperatureIndices, CollisionPartnerDensitiesIndices, FileName)
Scripts.DrawResults1Molecule(ComparisonTypeCodes.Intensities, result1, [1], [13], [1], [1], 'OpenNew','');
Scripts.DrawResults1Molecule(ComparisonTypeCodes.Intensities, result2, [1], [13], [1], [1], 'Add','');
