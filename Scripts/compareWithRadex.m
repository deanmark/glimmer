
%our calculation
Temperatures = cat(2, 100);

Densities = 10.^(9);

ColumnDensities = [1];

Molecule = MoleculeData_12CO;
CollisionPartnerToMoleculeDensityRatio = 10^-2;
CollisionPartners = [CollisionRates_12CO_H2ortho,CollisionRates_12CO_H2para];
CollisionPartnerWeights = [3 1];
dvdrKmParsec = Constants.dVdRConversionFactor^-1;

BackgroundTemperature = 2.73;

IgnoreNegativeTau = true;
IncludeBackgroundRadiation = true;

%BetaProvider = HomogeneousSlabBetaProvider(Molecule, IgnoreNegativeTau, IncludeBackgroundRadiation, BackgroundTemperature);
%BetaProvider = UniformSphereBetaProvider(Molecule, IgnoreNegativeTau, IncludeBackgroundRadiation, BackgroundTemperature);
BetaProvider = LVGBetaProvider(Molecule, IgnoreNegativeTau, IncludeBackgroundRadiation, BackgroundTemperature);

PopulationsLVG = Scripts.CalculateLVGPopulation(dvdrKmParsec, Densities, Temperatures, ColumnDensities, CollisionPartnerToMoleculeDensityRatio, Molecule, CollisionPartners, CollisionPartnerWeights, BetaProvider, false);

%radex calculation
Result = RadexSolver(dvdrKmParsec*Constants.dVdRConversionFactor,Densities,Temperatures,CollisionPartnerToMoleculeDensityRatio,Molecule,CollisionPartners,CollisionPartnerWeights,BackgroundTemperature);

Scripts.CompareWithRadex(Result.PopulationLow, PopulationsLVG(1:numel(Result.PopulationLow)), Densities, Temperatures, ColumnDensities);