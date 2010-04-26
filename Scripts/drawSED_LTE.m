Temperatures = cat(2, 5:100:2000);

Densities = 10.^(9);

CollisionPartnerToMoleculeDensityRatio = 10^-4;

Molecule = MoleculeData_12CO;

CollisionPartners = [CollisionRates_12CO_H2ortho,CollisionRates_12CO_H2para];

CollisionPartnerRatio = [3 1];

ColumnDensities = [2.5*10^18];

IntensitiesLTE = Scripts.DrawSEDLTE(Densities, Temperatures, ColumnDensities, Molecule, CollisionPartners, CollisionPartnerRatio);