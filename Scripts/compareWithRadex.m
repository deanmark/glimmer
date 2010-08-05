
%our calculation
Temperatures = cat(2, 1200);
%Temperatures = cat(2, 25:10:100, 100:100:2000);
%Temperatures = cat(2, 2000:200:10000);
%Densities = 10.^(7);
Densities = 10.^(1:1:7);

ColumnDensities = [1];

% Molecule = MoleculeData_12CO;
% MoleculeToCollisionPartnerDensityRatio = 8e-5;
% CollisionPartners = [CollisionRates_12CO_H2ortho,CollisionRates_12CO_H2para];
% CollisionPartnerWeights = [3 1];
% dvdrKmParsec = Constants.dVdRConversionFactor^-1;

Molecule = MoleculeData_HCOplus;
MoleculeToCollisionPartnerDensityRatio = 10^-5;
CollisionPartners = [CollisionRates_HCOplus_H2];
CollisionPartnerWeights = [1];
dvdrKmParsec = 1;

BackgroundTemperature = 2.73;

IgnoreNegativeTau = false;
IncludeBackgroundRadiation = true;

%BetaProvider = HomogeneousSlabBetaProvider(Molecule, IgnoreNegativeTau, IncludeBackgroundRadiation, BackgroundTemperature);
%BetaProvider = UniformSphereBetaProvider(Molecule, IgnoreNegativeTau, IncludeBackgroundRadiation, BackgroundTemperature);
BetaProvider = LVGBetaProvider(Molecule, IgnoreNegativeTau, IncludeBackgroundRadiation, BackgroundTemperature);

Results = zeros(numel(Temperatures),numel(Densities));

for temp = Temperatures
    fprintf(1, 'Progress -> Temperature: %g\n', temp);

    for dens = Densities
        PopulationsLVG = Scripts.CalculateLVGPopulation(dvdrKmParsec*Constants.dVdRConversionFactor, dens, temp, ColumnDensities, MoleculeToCollisionPartnerDensityRatio, Molecule, CollisionPartners, CollisionPartnerWeights, BetaProvider, false);
        
        %radex calculation
        [Result, RuntimeMessage] = RadexSolver.SolveLevelsPopulation (dvdrKmParsec*Constants.dVdRConversionFactor,dens,temp,MoleculeToCollisionPartnerDensityRatio,Molecule,CollisionPartners,CollisionPartnerWeights,BackgroundTemperature);

        FileName = sprintf('./pics/Temperature%g_%g.jpg', temp, find(Densities==dens));
        
        minLength = min(numel(Result.PopulationLow), numel(PopulationsLVG));
        
        Scripts.CompareWithRadex(Result.PopulationLow, PopulationsLVG, dens, temp, ColumnDensities, dvdrKmParsec, FileName);
        %Scripts.CompareWithRadex(Result.PopulationLow(1:minLength), PopulationsLVG(1:minLength), dens, temp, ColumnDensities, dvdrKmParsec);
        
        Ours = PopulationsLVG(1:minLength);
        radex = Result.PopulationLow(1:minLength);
        
        smallIndices = Ours < 0.001 | radex < 0.001;
        
        Ours(smallIndices) = 0;        
        radex(smallIndices) = 0;
        
        diff = (abs(Ours-radex)./mean(Result.PopulationLow(~smallIndices)));
       
        Results(find(Temperatures == temp,1),find(Densities == dens,1)) = 100*max(diff);
        if any (isnan(diff))
            'Error'
        end          
        
    end
end

generateComparisonResport;
