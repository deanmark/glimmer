Temperature = 1000;

Density = 10.^(7);

Molecule = MoleculeData_12CO;

CollisionPartners = [CollisionRates_12CO_H2ortho,CollisionRates_12CO_H2para];

CollisionPartnerRatio = [3 1];

Scripts.DrawBoltzmannFitOpticallyThin(Density, Temperature, Molecule, CollisionPartners, CollisionPartnerRatio);