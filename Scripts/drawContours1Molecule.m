Molecule = Molecules.Get('co.dat');
MoleculeToCollisionPartnerDensityRatio = 8e-5;
CollisionPartners = [CollisionPartnersCodes.H2ortho,CollisionPartnersCodes.H2para];
CollisionPartnerWeights = [3 1];

Temperatures = Molecule.GetCollisionPartner(CollisionPartners(1)).Temperatures;

CollisionPartnerDensities = 10.^(3:0.1:8);
%CollisionPartnerDensities = 10.^(2.8:0.2:7);

ColumnDensities = [1];

%dvdrKmParsecArray = 1:0.05:1.05;
dvdrKmParsecArray = 1;

BackgroundTemperature = 2.73;

IgnoreNegativeTau = false;
IncludeBackgroundRadiation = true;


req = LVGSolverPopulationRequest(Molecule, BetaProvider, CollisionPartners, CollisionPartnerWeights, Temperatures, CollisionPartnerDensities, ...
    dvdrKmParsecArray*Constants.dVdRConversionFactor, CollisionPartnerDensities*MoleculeToCollisionPartnerDensityRatio, Molecule.MolecularLevels, [], true, 1e5*CollisionPartnerDensities*MoleculeToCollisionPartnerDensityRatio/(dvdrKmParsec*Constants.dVdRConversionFactor));

ResultOurs = Scripts.CalculateLVGPopulation(req);
ResultsRadex = Scripts.CalculateRadexLVGPopulation (req);
% 
% 
% %levels != J . levels are count 1, J is count 0.
% LevelPairs = [41 25; 25 18];
% %LevelPairs = [41 25; 41 18];
% %LevelPairs = [25 18];
% 
% ContourLevels = {[0.1 0.2], [1 1.5]};
% 
% Scripts.DrawContours1Molecule(Temperatures, Densities, dvdrKmParsecs, LevelPairs, ContourLevels, Intensities, Molecule);