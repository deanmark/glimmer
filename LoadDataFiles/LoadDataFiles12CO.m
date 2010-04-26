
%enables you to multiply the collision rates by a certain factor.
%for example, when comparing data with Steven Dunsheath, use ratio = 1.21
collisionRateRatio = 1;

MoleculeData_12CO = MoleculeDataReaderLamdaFormat.CreateMoleculeDataFromFile('DataFiles/Lamda/12co.dat');
CollisionRates_12CO_H2para = CollisionRatesReaderLamdaFormat.CreateCollisionRatesFromFile('DataFiles/Lamda/12co.dat',2,MoleculeData_12CO,collisionRateRatio);
CollisionRates_12CO_H2ortho = CollisionRatesReaderLamdaFormat.CreateCollisionRatesFromFile('DataFiles/Lamda/12co.dat',3,MoleculeData_12CO,collisionRateRatio);