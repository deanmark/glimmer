Temperature = 2000;

Molecule = Molecules.Get('hco+@xpol.dat');

CollisionRates = Molecule.GetCollisionPartner(CollisionPartnersCodes.H2);

NCritical = Scripts.DrawCriticalDensities(Temperature, Molecule, CollisionRates);