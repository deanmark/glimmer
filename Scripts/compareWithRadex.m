
%our calculation
Temperatures = cat(2, 400);
%Temperatures = cat(2, 25:10:100, 100:100:2000);
%Temperatures = cat(2, 2000:200:10000);
%CollisionPartnerDensities = 10.^(3);
CollisionPartnerDensities = 10.^(1:1:7);

ColumnDensities = [1];

Molecule = MoleculeData_12CO;
MoleculeToCollisionPartnerDensityRatio = 8e-5;
CollisionPartners = [CollisionRates_12CO_H2ortho,CollisionRates_12CO_H2para];
CollisionPartnerWeights = [3 1];
dvdrKmParsec = 1;

% Molecule = MoleculeData_HCOplus;
% MoleculeToCollisionPartnerDensityRatio = 10^-8;
% CollisionPartners = [CollisionRates_HCOplus_H2];
% CollisionPartnerWeights = [1];
% dvdrKmParsec = 1;

BackgroundTemperature = 0;

IgnoreNegativeTau = false;
IncludeBackgroundRadiation = true;

%BetaProvider = HomogeneousSlabBetaProvider(Molecule, IgnoreNegativeTau, IncludeBackgroundRadiation, BackgroundTemperature);
%BetaProvider = UniformSphereBetaProvider(Molecule, IgnoreNegativeTau, IncludeBackgroundRadiation, BackgroundTemperature);
BetaProvider = RadexBetaProvider(Molecule, IgnoreNegativeTau, IncludeBackgroundRadiation, BackgroundTemperature);

p = mfilename('fullpath'); %returns path of current script.
ScriptsDirectory = fileparts(p);
picsPath = fullfile(ScriptsDirectory, '..', 'Results', 'RadexCompareOutput', 'pics');
[status, message, messageid] = rmdir(picsPath, 's');
mkdir(picsPath);

Results = zeros(numel(Temperatures),numel(CollisionPartnerDensities));

for temp = Temperatures
    fprintf(1, 'Progress -> Temperature: %g\n', temp);

    for dens = CollisionPartnerDensities        
        PopulationsLVG = Scripts.CalculateLVGPopulation(dvdrKmParsec*Constants.dVdRConversionFactor, dens, temp, MoleculeToCollisionPartnerDensityRatio, Molecule, CollisionPartners, CollisionPartnerWeights, BetaProvider, Molecule.MolecularLevels);
        
        %radex calculation
        [Result, RuntimeMessage] = RadexSolver.SolveLevelsPopulation (RadexSolver.LVG, dvdrKmParsec*Constants.dVdRConversionFactor,dens,temp,MoleculeToCollisionPartnerDensityRatio,Molecule,CollisionPartners,CollisionPartnerWeights,BackgroundTemperature);

        %Compare results using a graph
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
        
        diff = (abs(Ours-radex)./mean(Result.PopulationLow(~smallIndices)));
        
        Results(find(Temperatures == temp,1),find(CollisionPartnerDensities == dens,1)) = 100*max(diff);
        if any (isnan(diff))
            'Error'
        end          
        
    end
end

generateComparisonResport;