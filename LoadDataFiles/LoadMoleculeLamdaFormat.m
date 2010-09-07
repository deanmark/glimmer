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