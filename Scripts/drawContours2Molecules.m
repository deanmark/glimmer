%Temperatures = cat(2, 5:2.5:25, 29:4:50, 55:5:100, 105:10:200, 200:20:2000);
Temperatures = cat(2, 25:20:400, 400);
%Temperatures = cat(2, 55:5:100, 105:20:500);
CollisionPartnerDensities = 10.^(3:0.2:6);
%Densities = 10.^(6);
%dvdrKmParsecs = 20;
dvdrKmParsecs = [3 6 10 20 40 80];

Molecule1 = MoleculeData_12CO;
MoleculeToCollisionPartnerDensityRatio1 = 8e-5;
CollisionPartners1 = [CollisionRates_12CO_H2ortho,CollisionRates_12CO_H2para];
CollisionPartnerWeights1 = [3 1];

Molecule2 = MoleculeData_13CO;
MoleculeToCollisionPartnerDensityRatio2 = MoleculeToCollisionPartnerDensityRatio1/50;
CollisionPartners2 = [CollisionRates_13CO_H2ortho,CollisionRates_13CO_H2para];
CollisionPartnerWeights2 = [3 1];

BackgroundTemperature = 2.73;
IgnoreNegativeTau = false;
IncludeBackgroundRadiation = true;

BetaProvider1 = HomogeneousSlabBetaProvider(Molecule1, IgnoreNegativeTau, IncludeBackgroundRadiation, BackgroundTemperature);
BetaProvider2 = HomogeneousSlabBetaProvider(Molecule2, IgnoreNegativeTau, IncludeBackgroundRadiation, BackgroundTemperature);

for dvdrKmParsec = dvdrKmParsecs
    
    req1 = LVGSolverPopulationRequest(Molecule1, BetaProvider1, CollisionPartners1, CollisionPartnerWeights1, Temperatures, CollisionPartnerDensities, ...
        dvdrKmParsec*Constants.dVdRConversionFactor, CollisionPartnerDensities*MoleculeToCollisionPartnerDensityRatio1, Molecule1.MolecularLevels, [], true, 1);
    
    req2 = LVGSolverPopulationRequest(Molecule2, BetaProvider2, CollisionPartners2, CollisionPartnerWeights2, Temperatures, CollisionPartnerDensities, ...
        dvdrKmParsec*Constants.dVdRConversionFactor, CollisionPartnerDensities*MoleculeToCollisionPartnerDensityRatio2, Molecule2.MolecularLevels, [], true, ...
        MoleculeToCollisionPartnerDensityRatio2/MoleculeToCollisionPartnerDensityRatio1);
    
    %calculate
    Result1 = Scripts.CalculateRadexLVGPopulation(req1);
    Result2 = Scripts.CalculateRadexLVGPopulation(req2);
    
    Intensities1 = Result1.Intensities;
    Intensities2 = Result2.Intensities;
    
    %levels != J . levels are count 1, J is count 0.
    LevelPairs = ...
        [8 4 0 0;
        4 0 0 4];
    
    ContourLevels = {[0.3 1 3 10], [2.5 5 10 20 40]};
    
    Scripts.DrawContours2Molecules(Temperatures, CollisionPartnerDensities, dvdrKmParsec, LevelPairs, ContourLevels, Intensities1, Molecule1, Intensities2, Molecule2);

end