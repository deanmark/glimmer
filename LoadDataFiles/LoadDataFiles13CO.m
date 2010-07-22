
%enables you to multiply the collision rates by a certain factor.
%for example, when comparing data with Steven Dunsheath, use ratio = 1.21
collisionRateRatio = 1;

MoleculeData_13CO = MoleculeDataReaderLamdaFormat.CreateMoleculeDataFromFile('DataFiles/Lamda/13co.dat');
CollisionRates_13CO_H2para = CollisionRatesReaderLamdaFormat.CreateCollisionRatesFromFile('DataFiles/Lamda/13co.dat',CollisionPartnersCodes.H2para,MoleculeData_13CO,collisionRateRatio);
CollisionRates_13CO_H2ortho = CollisionRatesReaderLamdaFormat.CreateCollisionRatesFromFile('DataFiles/Lamda/13co.dat',CollisionPartnersCodes.H2ortho,MoleculeData_13CO,collisionRateRatio);