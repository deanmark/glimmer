%Temperatures = cat(2, 5:2.5:25, 29:4:50, 55:5:100, 105:10:200, 200:20:2000);
Temperatures = cat(2, 25:10:200);
%Temperatures = cat(2, 55:5:100, 105:20:500);
Densities = 10.^(2:0.1:8);
%Densities = 10.^(6);
dvdrKmParsecs = 20;
%dvdrKmParsecs = [1 2 3 5 6 8 9 10 15 20 40];
BackgroundTemperature = 2.73;

Molecule1 = MoleculeData_HCOplus;
CollisionPartnerToMoleculeDensityRatio1 = 10^-8;
CollisionPartners1 = [CollisionRates_HCOplus_H2];
CollisionPartnerWeights1 = [1];

Molecule2 = MoleculeData_HCN;
CollisionPartnerToMoleculeDensityRatio2 = 10^-9;
CollisionPartners2 = [CollisionRates_HCN_H2];
CollisionPartnerWeights2 = [1];

%calculate
Intensities1 = Scripts.CalculateLVGLineIntensities(dvdrKmParsecs, Densities, Temperatures, 1, BackgroundTemperature, Molecule1, CollisionPartners1, CollisionPartnerWeights1, CollisionPartnerToMoleculeDensityRatio1);
Intensities2 = Scripts.CalculateLVGLineIntensities(dvdrKmParsecs, Densities, Temperatures, CollisionPartnerToMoleculeDensityRatio2/CollisionPartnerToMoleculeDensityRatio1, BackgroundTemperature, Molecule2, CollisionPartners2, CollisionPartnerWeights2, CollisionPartnerToMoleculeDensityRatio2);

%levels != J . levels are count 1, J is count 0.
LevelPairs = ...
[0 2 2 0];

ContourLevels = {100};
%ContourLevels = {[1 2]};

Scripts.DrawContours2Molecules(Temperatures, Densities, dvdrKmParsecs, LevelPairs, ContourLevels, Intensities1, Molecule1, Intensities2, Molecule2);