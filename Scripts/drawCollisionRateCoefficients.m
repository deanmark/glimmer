Temperature = 500;

Molecule = Molecules.Get('co.dat');

CollisionRates = Molecule.GetCollisionPartner(CollisionPartnersCodes.H2para);

NumContourLevels = 100;

Scripts.DrawCollisionRateCoefficients(Temperature, CollisionRates, NumContourLevels);