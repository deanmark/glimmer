Temperatures = cat(2, 5:100:2000);

Densities = 10.^(9);

ColumnDensities = [2.5*10^18];

CollisionPartnerToMoleculeDensityRatio = 10^-4;

Molecule = MoleculeData_12CO;

CollisionPartners = [CollisionRates_12CO_H2ortho,CollisionRates_12CO_H2para];

CollisionPartnerRatio = [3 1];

dvdrKmParsec = 20;

BackgroundTemperature = 2.73;

IgnoreNegativeTau = true;
IncludeBackgroundRadiation = true;

%BetaProvider = HomogeneousSlabBetaProvider(Molecule, IgnoreNegativeTau, IncludeBackgroundRadiation, BackgroundTemperature);
%BetaProvider = UniformSphereBetaProvider(Molecule, IgnoreNegativeTau, IncludeBackgroundRadiation, BackgroundTemperature);
BetaProvider = LVGBetaProvider(Molecule, IgnoreNegativeTau, IncludeBackgroundRadiation, BackgroundTemperature);

IntensitiesLVG = Scripts.DrawSEDLVG(dvdrKmParsec, Densities, Temperatures, ColumnDensities, CollisionPartnerToMoleculeDensityRatio, Molecule, CollisionPartners, CollisionPartnerRatio, BetaProvider);