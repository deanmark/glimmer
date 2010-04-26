
%enables you to multiply the collision rates by a certain factor.
%for example, when comparing data with Steven Dunsheath, use ratio = 1.21
collisionRateRatio = 1;

MoleculeData_HCN = MoleculeDataReaderLamdaFormat.CreateMoleculeDataFromFile('DataFiles/Lamda/hcn@xpol.dat');
CollisionRates_HCN_H2 = CollisionRatesReaderLamdaFormat.CreateCollisionRatesFromFile('DataFiles/Lamda/hcn@xpol.dat',1,MoleculeData_HCN,collisionRateRatio);