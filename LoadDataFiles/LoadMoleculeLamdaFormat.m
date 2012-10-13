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

function Molecule = LoadMoleculeLamdaFormat( FileName , CollisionRateRatio)
%LOADMOLECULE Loads molecule with collision rates

%enables you to multiply the collision rates by a certain factor.
%for example, when comparing data with Steven Dunsheath, use ratio = 1.21
if nargin == 1
    CollisionRateRatio = 1;
end

%fileName = 'DataFiles/Lamda/12co.dat';

Molecule = MoleculeDataReaderLamdaFormat.CreateMoleculeDataFromFile(FileName);
collisionPartnerCodes = CollisionRatesReaderLamdaFormat.ListAllCollisionPartners(FileName);

CollisionPartners = cell([1 numel(collisionPartnerCodes)]);

for i = 1:numel(collisionPartnerCodes)
    
    CollisionPartners{i} = CollisionRatesReaderLamdaFormat.CreateCollisionRatesFromFile(FileName,collisionPartnerCodes(i),Molecule,CollisionRateRatio);
    
end

Molecule.AddCollisionPartners(CollisionPartners);

end
