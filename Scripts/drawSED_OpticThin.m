Temperatures = cat(2, 5:100:2000);

Densities = 10.^(9);

ColumnDensities = [2.5*10^18];

CollisionPartnerToMoleculeDensityRatio = 10^-4;

Molecule = MoleculeData_12CO;

CollisionPartners = [CollisionRates_12CO_H2ortho,CollisionRates_12CO_H2para];

CollisionPartnerRatio = [3 1];

IntensitiesOthin = Scripts.DrawSEDOpticallyThin(Densities, Temperatures, ColumnDensities, Molecule, CollisionPartners, CollisionPartnerRatio);