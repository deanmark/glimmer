
%our calculation
%Temperatures = cat(2, 25:10:100, 100:100:2000);
%Temperatures = cat(2, 1700:100:2000);

%Temperatures = cat(2, 2000);

Temperatures = CollisionRates_12CO_H2ortho.m_temperatures;
%Temperatures = CollisionRates_HCOplus_H2.m_temperatures;
%Temperatures = CollisionRates_HCN_H2.m_temperatures;

%CollisionPartnerDensities = 10.^(6);
CollisionPartnerDensities = 10.^(1:1:7);
%CollisionPartnerDensities = 10.^(2.8:0.2:7);

ColumnDensities = [1];
% 
Molecule = MoleculeData_12CO;
MoleculeToCollisionPartnerDensityRatio = 8e-5;
CollisionPartners = [CollisionRates_12CO_H2ortho,CollisionRates_12CO_H2para];
CollisionPartnerWeights = [3 1];
 
% Molecule = MoleculeData_HCOplus;
% MoleculeToCollisionPartnerDensityRatio = 10^-8;
% CollisionPartners = [CollisionRates_HCOplus_H2];
% CollisionPartnerWeights = [1];

% Molecule = MoleculeData_HCN;
% MoleculeToCollisionPartnerDensityRatio = 10^-8;
% CollisionPartners = [CollisionRates_HCN_H2];
% CollisionPartnerWeights = [1];

%dvdrKmParsecArray = 1:0.05:1.05;
dvdrKmParsecArray = 1;

BackgroundTemperature = 2.73;

IgnoreNegativeTau = false;
IncludeBackgroundRadiation = true;

%Parameters for LVG algorithm
fastParams = LVGSolverAlgorithmParameters();
fastParams.MaxIterations = 1500;
fastParams.ChangePercent = 0.01;
slowParams = LVGSolverAlgorithmParameters();
slowParams.MaxIterations = 5000;
slowParams.ChangePercent = 0.000001;

%BetaProvider = HomogeneousSlabBetaProvider(Molecule, IgnoreNegativeTau, IncludeBackgroundRadiation, BackgroundTemperature);
%BetaProvider = UniformSphereBetaProvider(Molecule, IgnoreNegativeTau, IncludeBackgroundRadiation, BackgroundTemperature);
BetaProvider = HomogeneousSlabBetaProvider(Molecule, IgnoreNegativeTau, IncludeBackgroundRadiation, BackgroundTemperature);

p = mfilename('fullpath'); %returns path of current script.
ScriptsDirectory = fileparts(p);
picsPath = fullfile(ScriptsDirectory, '..', 'Results', 'RadexCompareOutput', 'pics');
[status, message, messageid] = rmdir(picsPath, 's');
mkdir(picsPath);

Results = zeros(numel(Temperatures),numel(CollisionPartnerDensities));
for dvdrKmParsec = dvdrKmParsecArray
    for temp = Temperatures
        fprintf(1, 'Progress -> Temperature: %g\n', temp);
        
        for dens = CollisionPartnerDensities
            
            req = LVGSolverPopulationRequest(CollisionPartners, CollisionPartnerWeights, temp, dens, dvdrKmParsec*Constants.dVdRConversionFactor, dens*MoleculeToCollisionPartnerDensityRatio, Molecule.MolecularLevels, []);
            
            PopulationsLVG = Scripts.CalculateLVGPopulation(fastParams, slowParams, Molecule, BetaProvider, req);
            
            %dvdrKmParsec*Constants.dVdRConversionFactor,dens,temp,MoleculeToCollisionPartnerDensityRatio,,CollisionPartners,CollisionPartnerWeights
            %radex calculation
            [Result, RadexConverged, RuntimeMessage] = RadexSolver.SolveLevelsPopulationLVG (Molecule, RadexSolver.PlaneParallelSlab, BackgroundTemperature, req);
            
            %Compare results using a graph
            %picFileName = sprintf('Temperature%g_%g.jpg',temp, find(dvdrKmParsecArray==dvdrKmParsec));
            picFileName = sprintf('Temperature%g_%g.jpg',temp, find(CollisionPartnerDensities==dens));
            FileName = fullfile(picsPath, picFileName);
            
            minLength = min(numel(Result.PopulationLow), numel(PopulationsLVG));
            
            Scripts.CompareWithRadex(Result.PopulationLow, PopulationsLVG, dens, temp, dvdrKmParsec, FileName);
            
            % Calculate difference between codes
            Ours = PopulationsLVG(1:minLength);
            radex = Result.PopulationLow(1:minLength);
            
            smallIndices = Ours < 0.001 | radex < 0.001;
            
            Ours(smallIndices) = 0;
            radex(smallIndices) = 0;
            maxPop = max (Ours, radex);
            
            diff = (abs(Ours-radex)./mean(maxPop(~smallIndices)));
            
            %Results(find(Temperatures == temp,1),find(dvdrKmParsecArray == dvdrKmParsec,1)) = 100*max(diff);
            Results(find(Temperatures == temp,1),find(CollisionPartnerDensities == dens,1)) = 100*max(diff);
            if any (isnan(diff)) || RadexConverged == 0
                'Error'
            end
            
        end
    end
end

generateComparisonResport;