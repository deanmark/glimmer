
%enables you to multiply the collision rates by a certain factor.
%for example, when comparing data with Steven Dunsheath, use ratio = 1.21
collisionRateRatio = 1;

MoleculeData_HCOplus = MoleculeDataReaderLamdaFormat.CreateMoleculeDataFromFile('DataFiles/Lamda/hco+@xpol.dat');
CollisionRates_HCOplus_H2 = CollisionRatesReaderLamdaFormat.CreateCollisionRatesFromFile('DataFiles/Lamda/hco+@xpol.dat',CollisionPartnersCodes.H2,MoleculeData_HCOplus,collisionRateRatio);