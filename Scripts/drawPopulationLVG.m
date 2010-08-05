Temperatures = cat(2, 200, 300);

Densities = 10.^(5:1:10);

ColumnDensities = [1];

CollisionPartnerToMoleculeDensityRatio = 10^-4;

Molecule = MoleculeData_HCN;

CollisionPartners = [CollisionRates_HCN_H2];

CollisionPartnerRatio = [1];

dvdrKmParsec = 2*Constants.dVdRConversionFactor^-1;

BackgroundTemperature = 2.73;

IgnoreNegativeTau = true;
IncludeBackgroundRadiation = true;

%BetaProvider = HomogeneousSlabBetaProvider(Molecule, IgnoreNegativeTau, IncludeBackgroundRadiation, BackgroundTemperature);
%BetaProvider = UniformSphereBetaProvider(Molecule, IgnoreNegativeTau, IncludeBackgroundRadiation, BackgroundTemperature);
BetaProvider = LVGBetaProvider(Molecule, IgnoreNegativeTau, IncludeBackgroundRadiation, BackgroundTemperature);

PopulationsLVG = Scripts.CalculateLVGPopulation(dvdrKmParsec, Densities, Temperatures, ColumnDensities, CollisionPartnerToMoleculeDensityRatio, Molecule, CollisionPartners, CollisionPartnerRatio, BetaProvider, true);