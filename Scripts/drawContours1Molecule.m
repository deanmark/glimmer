%Temperatures = cat(2, 5:2.5:25, 29:4:50, 55:5:100, 105:10:200, 200:20:2000);
Temperatures = cat(2, 140:10:300);
%Temperatures = cat(2, 55:5:100, 105:20:500);
Densities = 10.^(2:0.1:8);
%Densities = 10.^(6);
dvdrKmParsecs = 20;
%dvdrKmParsecs = [1 2 3 5 6 8 9 10 15 20 40];
BackgroundTemperature = 2.73;

Molecule = MoleculeData_12CO;
CollisionPartnerToMoleculeDensityRatio = 10^-4;
CollisionPartners = [CollisionRates_12CO_H2ortho,CollisionRates_12CO_H2para];
CollisionPartnerWeights = [3 1];

Intensities = Scripts.CalculateLVGLineIntensities(dvdrKmParsecs, Densities, Temperatures, 1, BackgroundTemperature, Molecule, CollisionPartners, CollisionPartnerWeights, CollisionPartnerToMoleculeDensityRatio);

%levels != J . levels are count 1, J is count 0.
LevelPairs = [41 25; 25 18];
%LevelPairs = [41 25; 41 18];
%LevelPairs = [25 18];

ContourLevels = {[0.1 0.2], [1 1.5]};

Scripts.DrawContours1Molecule(Temperatures, Densities, dvdrKmParsecs, LevelPairs, ContourLevels, Intensities, Molecule);