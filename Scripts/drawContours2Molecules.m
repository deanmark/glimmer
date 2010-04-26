%Temperatures = cat(2, 5:2.5:25, 29:4:50, 55:5:100, 105:10:200, 200:20:2000);
Temperatures = cat(2, 25:10:400);
%Temperatures = cat(2, 55:5:100, 105:20:500);
Densities = 10.^(3:0.1:6);
%Densities = 10.^(6);
dvdrKmParsecs = 20;
%dvdrKmParsecs = [1 2 3 5 6 8 9 10 15 20 40];
BackgroundTemperature = 2.73;

Molecule1 = MoleculeData_12CO;
CollisionPartnerToMoleculeDensityRatio1 = 10^-4;
CollisionPartners1 = [CollisionRates_12CO_H2ortho,CollisionRates_12CO_H2para];
CollisionPartnerWeights1 = [3 1];

Molecule2 = MoleculeData_13CO;
CollisionPartnerToMoleculeDensityRatio2 = 10^-4/50;
CollisionPartners2 = [CollisionRates_13CO_H2ortho,CollisionRates_13CO_H2para];
CollisionPartnerWeights2 = [3 1];

%calculate
Intensities1 = Scripts.CalculateLVGLineIntensities(dvdrKmParsecs, Densities, Temperatures, 1, BackgroundTemperature, Molecule1, CollisionPartners1, CollisionPartnerWeights1, CollisionPartnerToMoleculeDensityRatio1);
Intensities2 = Scripts.CalculateLVGLineIntensities(dvdrKmParsecs, Densities, Temperatures, CollisionPartnerToMoleculeDensityRatio2/CollisionPartnerToMoleculeDensityRatio1, BackgroundTemperature, Molecule2, CollisionPartners2, CollisionPartnerWeights2, CollisionPartnerToMoleculeDensityRatio2);

%levels != J . levels are count 1, J is count 0.
LevelPairs = ...
[8 3 0 0;
4 0 0 4];

ContourLevels = {[0.3 1 3 10 30], [5 10 20 40]};

Scripts.DrawContours2Molecules(Temperatures, Densities, dvdrKmParsecs, LevelPairs, ContourLevels, Intensities1, Molecule1, Intensities2, Molecule2);