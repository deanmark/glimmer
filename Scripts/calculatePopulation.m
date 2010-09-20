function calculatePopulation()

MoleculeFileName = 'hcn.dat';
%MoleculeFileName = 'hco+@xpol.dat';
%MoleculeToCollisionPartnerDensityRatio = 10^-8;
CollisionPartners = [CollisionPartnersCodes.H2];
CollisionPartnerWeights = [1];

Molecule = WorkspaceHelper.GetMoleculeDataFromWorkspace(MoleculeFileName);
%Temperatures = Molecule.GetCollisionPartner(CollisionPartners(1)).Temperatures;
Temperatures = 60;

%CollisionPartnerDensities = 15e3:1000:20e3;
a=(1:2:10)'*(10.^(3:1:7));
CollisionPartnerDensities = [a(:)'];
%CollisionPartnerDensities = 1e4:1000:4e4;

%MoleculeDensity = CollisionPartnerDensities*MoleculeToCollisionPartnerDensityRatio;
MoleculeDensity = ones(size(CollisionPartnerDensities)).*10^6*2;
ColumnDensities = MoleculeDensity;

%dvdrKmParsecArray = 1:0.05:1.05 .* Constants.dVdRConversionFactor;
dvdrArray = 10.^[ -5:0.1:1 ];

BackgroundTemperature = 2.73;

req = LVGSolverPopulationRequest(RunTypeCodes.LVG, MoleculeFileName, BetaTypeCodes.UniformSphere, BackgroundTemperature, CollisionPartners, CollisionPartnerWeights, Temperatures, CollisionPartnerDensities, ...
    dvdrArray , MoleculeDensity, Molecule.MolecularLevels, [], true, ColumnDensities);

LVGResults = WorkspaceHelper.GetLVGResultsHashFromWorkspace();
solver = PopulationSolverHelper();

LVGResults.Put('HCN - T60K x 2',solver.ProcessPopulationRequest(req));


end