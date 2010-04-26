Temperature = 400;

Density = 10.^(6);

CollisionPartnerToMoleculeDensityRatio = 10^-4;

Molecule = MoleculeData_12CO;

CollisionPartners = [CollisionRates_12CO_H2ortho,CollisionRates_12CO_H2para];

CollisionPartnerRatio = [3 1];

dvdrKmParsec = 0.1;

BackgroundTemperature = 2.73;

IgnoreNegativeTau = true;
IncludeBackgroundRadiation = true;

%BetaProvider = HomogeneousSlabBetaProvider(Molecule, IgnoreNegativeTau, IncludeBackgroundRadiation, BackgroundTemperature);
BetaProvider = UniformSphereBetaProvider(Molecule, IgnoreNegativeTau, IncludeBackgroundRadiation, BackgroundTemperature);
%BetaProvider = LVGBetaProvider(Molecule, IgnoreNegativeTau, IncludeBackgroundRadiation, BackgroundTemperature);

Scripts.DrawBoltzmannFitLVG (dvdrKmParsec, Density, Temperature, CollisionPartnerToMoleculeDensityRatio, Molecule, CollisionPartners, CollisionPartnerRatio, BetaProvider)