MoleculeFileName = 'co.dat';
MoleculeToCollisionPartnerDensityRatio = 8e-5;
CollisionPartners = [CollisionPartnersCodes.H2ortho,CollisionPartnersCodes.H2para];
CollisionPartnerWeights = [3 1];

Molecule = WorkspaceHelper.GetMoleculeDataFromWorkspace(MoleculeFileName);
%Temperatures = Molecule.GetCollisionPartner(CollisionPartners(1)).Temperatures;
Temperatures = 200;

%CollisionPartnerDensities = 15e3:1000:20e3;
%a=(2:2:10)'*(10.^(1:1:7));
%CollisionPartnerDensities = [10 a(:)'];
CollisionPartnerDensities = 1e4:1000:4e4;

ColumnDensities = [1];

%dvdrKmParsecArray = 1:0.05:1.05;
dvdrKmParsecArray = 1;

BackgroundTemperature = 2.73;

req = LVGSolverPopulationRequest(RunTypeCodes.LVG, MoleculeFileName, BetaTypeCodes.HomogeneousSlab, BackgroundTemperature, CollisionPartners, CollisionPartnerWeights, Temperatures, CollisionPartnerDensities, ...
    dvdrKmParsecArray*Constants.dVdRConversionFactor, CollisionPartnerDensities*MoleculeToCollisionPartnerDensityRatio, Molecule.MolecularLevels, [], true, 1e5*CollisionPartnerDensities*MoleculeToCollisionPartnerDensityRatio/(dvdrKmParsecArray(1)*Constants.dVdRConversionFactor));

PopulationSolverHelper.ProcessPopulationRequest(req);
%LVGResults.Put('12CO - DVDR1 - 200', PopulationSolverHelper.ProcessPopulationRequest(req));

% 
% ResultLVG_CO = LVGResults.Get('12CO - DVDR10');
% % 
% %levels != J . levels are count 1, J is count 0.
% %LevelPairs = [41 25; 25 18];
% LevelPairs = [16 15; 16 20];
% %LevelPairs = [26 21];
% 
% ContourLevels = {[1.0826 1.0826],[3.6358 3.6358]};
% %ContourLevels = {[5.959*0.94 5.959*1.06]};
% 
% Scripts.DrawContours1Molecule(ResultLVG_CO, LevelPairs, ContourLevels);
% 
% %Scripts.DrawMax1Molecule(ResultsRadex, ContourLevels);